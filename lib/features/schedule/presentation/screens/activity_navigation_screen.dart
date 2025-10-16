 
 
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mapbox_config.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityNavigationScreen extends StatefulWidget {
  final ActivityEntity activity;
  final double? destinationLat;
  final double? destinationLng;

  const ActivityNavigationScreen({super.key, required this.activity, this.destinationLat, this.destinationLng});

  @override
  State<ActivityNavigationScreen> createState() => _ActivityNavigationScreenState();
}

class _ActivityNavigationScreenState extends State<ActivityNavigationScreen> {
  mb.MapboxMap? _map;
  final Dio _dio = Dio();
  mb.PointAnnotationManager? _annotationManager;
  mb.PolylineAnnotationManager? _polylineManager;

  mb.Point? _userPoint;
  mb.Point? _destPoint;
  bool _isLoading = true;
  String? _error;
  String? _etaText;

  @override
  void initState() {
    super.initState();
    final token = MapboxConfig.accessToken;
    if (token.isNotEmpty) {
      mb.MapboxOptions.setAccessToken(token);
    }
    _initFlow();
  }

  Future<void> _initFlow() async {
    try {
      final hasLocation = await _ensureLocationPermission();
      if (!hasLocation) {
        if (mounted) {
          // If user denied permission or location services are off, exit this screen
          Navigator.of(context).maybePop();
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _userPoint = mb.Point(coordinates: mb.Position(pos.longitude, pos.latitude));

      if (widget.destinationLat != null && widget.destinationLng != null) {
        _destPoint = mb.Point(coordinates: mb.Position(widget.destinationLng!, widget.destinationLat!));
      } else {
        _destPoint = await _geocodeAddress(widget.activity.location);
      }

      if (_map != null && _destPoint != null) {
        await _enableUserPuck();
        await _showDestinationMarker();
        await _moveCameraToDestination();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Không thể khởi tạo bản đồ: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _enableUserPuck() async {
    try {
      await _map?.location.updateSettings(mb.LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        showAccuracyRing: true,
      ));
    } catch (_) {}
  }

  Future<void> _showDestinationMarker() async {
    if (_map == null || _destPoint == null) return;
    _annotationManager ??= await _map!.annotations.createPointAnnotationManager();
    await _annotationManager!.deleteAll();
    final bytes = await _buildMarkerBytes();
    await _annotationManager!.create(mb.PointAnnotationOptions(
      geometry: _destPoint!,
      image: bytes,
    ));
  }

  Future<Uint8List> _buildMarkerBytes() async {
    // Render Flutter's location_on icon in orange to PNG bytes
    const double size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final iconStr = String.fromCharCode(Icons.location_on.codePoint);
    final textSpan = TextSpan(
      text: iconStr,
      style: TextStyle(
        fontFamily: Icons.location_on.fontFamily,
        fontSize: size,
        color: const Color(0xFFFF0000), // orange
      ),
    );
    textPainter.text = textSpan;
    textPainter.layout();
    final offset = Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2);
    textPainter.paint(canvas, offset);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      return false;
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    return true;
  }

  Future<mb.Point> _geocodeAddress(String query) async {
    final token = MapboxConfig.accessToken;
    if (token.isEmpty) throw 'Thiếu MAPBOX_PUBLIC_TOKEN trong .env';
    final url = 'https://api.mapbox.com/search/geocode/v6/forward';
    final params = {
      'q': query,
      'access_token': token,
      'limit': '1',
      'language': 'vi',
      if (_userPoint != null)
        'proximity': '${_userPoint!.coordinates.lng.toStringAsFixed(6)},${_userPoint!.coordinates.lat.toStringAsFixed(6)}',
    };
    final res = await _dio.get(url, queryParameters: params);
    final features = (res.data['features'] as List?) ?? [];
    if (features.isEmpty) throw 'Không tìm thấy toạ độ cho địa chỉ';
    final feat = features.first as Map<String, dynamic>;
    List coords;
    if (feat['geometry'] != null && feat['geometry']['coordinates'] is List) {
      coords = feat['geometry']['coordinates'] as List;
    } else if (feat['center'] is List) {
      coords = feat['center'] as List;
    } else if (feat['coordinates'] is List) {
      coords = feat['coordinates'] as List;
    } else {
      throw 'Phản hồi geocoding không hợp lệ';
    }
    final lng = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();
    return mb.Point(coordinates: mb.Position(lng, lat));
  }

  Future<void> _fetchEta() async {
    if (_userPoint == null || _destPoint == null) return;
    final token = MapboxConfig.accessToken;
    final coordinates = '${_userPoint!.coordinates.lng.toStringAsFixed(6)},${_userPoint!.coordinates.lat.toStringAsFixed(6)};${_destPoint!.coordinates.lng.toStringAsFixed(6)},${_destPoint!.coordinates.lat.toStringAsFixed(6)}';
    // If origin and destination are the same (or extremely close), short-circuit
    final dx = (_userPoint!.coordinates.lng - _destPoint!.coordinates.lng).abs();
    final dy = (_userPoint!.coordinates.lat - _destPoint!.coordinates.lat).abs();
    if (dx < 0.00001 && dy < 0.00001) {
      _etaText = '~ 0.0 km • 0 phút';
      return;
    }

    Future<void> request(String profile, String geometries) async {
      final url = 'https://api.mapbox.com/directions/v5/mapbox/$profile/$coordinates';
      final res = await _dio.get(url, queryParameters: {
        'alternatives': 'false',
        'geometries': geometries,
        'overview': 'full',
        'steps': 'false',
        'language': 'vi',
        'access_token': token,
      });
      final routes = (res.data['routes'] as List?) ?? [];
      if (routes.isEmpty) throw 'Không tìm thấy lộ trình phù hợp';
      final route = routes.first;
      final durationSec = (route['duration'] as num).toDouble();
      final distanceM = (route['distance'] as num).toDouble();
      _etaText = _formatEta(distanceM, durationSec);

      // Draw route polyline if geometry available (geojson)
      if (route['geometry'] is Map) {
        final geom = route['geometry'] as Map<String, dynamic>;
        final coords = (geom['coordinates'] as List).cast<List>();
        final positions = coords
            .map((c) => mb.Position((c[0] as num).toDouble(), (c[1] as num).toDouble()))
            .toList();
        await _drawPolyline(positions);
      }
    }
    try {
      await request('driving-traffic', 'geojson');
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Try driving basic, then walking/cycling as graceful fallback
        try {
          await request('driving', 'geojson');
        } on DioException catch (_) {
          try {
            await request('walking', 'geojson');
          } on DioException catch (_) {
            await request('cycling', 'geojson');
          }
        }
      } else {
        // Surface server message to help debugging
        final msg = e.response?.data is Map<String, dynamic>
            ? (e.response!.data['message']?.toString() ?? e.message)
            : e.message;
        throw 'Directions API error: ${e.response?.statusCode} ${msg ?? ''}'.trim();
      }
    }
  }

  Future<void> _drawPolyline(List<mb.Position> positions) async {
    if (_map == null || positions.isEmpty) return;
    _polylineManager ??= await _map!.annotations.createPolylineAnnotationManager();
    await _polylineManager!.deleteAll();
    await _polylineManager!.create(mb.PolylineAnnotationOptions(
      geometry: mb.LineString(coordinates: positions),
      lineColor: AppColors.primary.value,
      lineWidth: 6.0,
    ));
  }

  Future<void> _moveCameraToDestination() async {
    if (_map == null || _destPoint == null) return;
    final camera = mb.CameraOptions(center: _destPoint, zoom: 14.0);
    await _map!.setCamera(camera);
  }

  void _onMapCreated(mb.MapboxMap mapboxMap) {
    _map = mapboxMap;
    _initFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.activity.placeName)),
      body: Stack(
        children: [
          mb.MapWidget(
            key: const ValueKey('activity-map'),
            styleUri: mb.MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: Material(
                color: Colors.red.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          if (_etaText != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 88 + MediaQuery.of(context).padding.bottom,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_etaText!, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: (_userPoint != null && _destPoint != null && !_isLoading) ? () async {
                try {
                  setState(() { _etaText = null; _error = null; _isLoading = true; });
                  await _fetchEta();
                } catch (e) {
                  setState(() { _error = e.toString(); });
                } finally {
                  setState(() { _isLoading = false; });
                }
              } : null,
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Bắt đầu điều hướng'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEta(double distanceM, double durationSec) {
    final km = (distanceM / 1000).toStringAsFixed(1);
    final mins = (durationSec / 60).round();
    return '~ $km km • $mins phút';
  }
}


