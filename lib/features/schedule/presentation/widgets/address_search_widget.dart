import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/mapbox_geocoding_response.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class AddressSearchWidget extends StatefulWidget {
  final Function(String placeName, String location, String? latitude, String? longitude) onAddressSelected;
  final String? initialLocation;

  const AddressSearchWidget({
    super.key,
    required this.onAddressSelected,
    this.initialLocation,
  });

  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  final _searchController = TextEditingController();
  List<Feature> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _searchController.text = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    context.read<ScheduleBloc>().add(SearchAddressEvent(query: query));
  }

  void _selectAddress(Feature feature) {
    final coordinates = feature.geometry.coordinates;
    final latitude = coordinates[1].toString();
    final longitude = coordinates[0].toString();
    
    // Use the new response structure
    final placeName = feature.properties.name ?? feature.properties.namePreferred ?? '';
    final address = feature.properties.fullAddress ?? feature.properties.placeFormatted ?? '';

    widget.onAddressSelected(placeName, address, latitude, longitude);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm địa chỉ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ cần tìm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.length >= 3) {
                  _performSearch(value);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<ScheduleBloc, ScheduleState>(
              listener: (context, state) {
                if (state is SearchAddressSuccess) {
                  setState(() {
                    _searchResults = state.response.features;
                    _isSearching = false;
                  });
                } else if (state is SearchAddressFailure) {
                  setState(() {
                    _isSearching = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi tìm kiếm: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (_isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nhập địa chỉ để tìm kiếm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final feature = _searchResults[index];
                    final properties = feature.properties;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          properties.name ?? properties.namePreferred ?? 'Không có tên',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (properties.fullAddress != null)
                              Text(properties.fullAddress!),
                            if (properties.placeFormatted != null)
                              Text(properties.placeFormatted!),
                            if (properties.context?.locality?.name != null)
                              Text('${properties.context!.locality!.name}, ${properties.context?.place?.name ?? ''}'),
                            if (properties.context?.country?.name != null)
                              Text(properties.context!.country!.name!),
                          ],
                        ),
                        onTap: () => _selectAddress(feature),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
