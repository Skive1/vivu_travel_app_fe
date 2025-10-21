import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/constants/mapbox_config.dart';
import '../models/mapbox_geocoding_response.dart';

abstract class MapboxGeocodingDataSource {
  Future<MapboxGeocodingResponse> searchAddress(String query);
  Future<MapboxGeocodingResponse> searchAddressStructured({
    String? addressNumber,
    String? street,
    String? locality,
    String? region,
    String? country,
  });
}

class MapboxGeocodingDataSourceImpl implements MapboxGeocodingDataSource {
  final Dio _dio;

  MapboxGeocodingDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<MapboxGeocodingResponse> searchAddress(String query) async {
    try {
      final response = await _dio.get(
        Endpoints.mapboxGeocoding,
        queryParameters: {
          'q': query,
          'access_token': MapboxConfig.accessToken,
          'limit': '10',
          'country': 'VN', // Vietnam
          'language': 'vi',
        },
      );

      return MapboxGeocodingResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to search address: ${e.message}');
    }
  }

  @override
  Future<MapboxGeocodingResponse> searchAddressStructured({
    String? addressNumber,
    String? street,
    String? locality,
    String? region,
    String? country,
  }) async {
    try {
      final queryParams = <String, String>{
        'access_token': MapboxConfig.accessToken,
        'limit': '10',
        'language': 'vi',
      };

      if (addressNumber != null) queryParams['address_number'] = addressNumber;
      if (street != null) queryParams['street'] = street;
      if (locality != null) queryParams['locality'] = locality;
      if (region != null) queryParams['region'] = region;
      if (country != null) queryParams['country'] = country;

      final response = await _dio.get(
        Endpoints.mapboxGeocoding,
        queryParameters: queryParams,
      );

      return MapboxGeocodingResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to search structured address: ${e.message}');
    }
  }
}
