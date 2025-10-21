import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/mapbox_geocoding_response.dart';

class SearchAddressUseCase implements UseCase<MapboxGeocodingResponse, String> {
  final ScheduleRepository _repository;

  SearchAddressUseCase(this._repository);

  @override
  Future<Either<Failure, MapboxGeocodingResponse>> call(String query) async {
    return await _repository.searchAddress(query);
  }
}

class SearchAddressStructuredUseCase implements UseCase<MapboxGeocodingResponse, SearchAddressStructuredParams> {
  final ScheduleRepository _repository;

  SearchAddressStructuredUseCase(this._repository);

  @override
  Future<Either<Failure, MapboxGeocodingResponse>> call(SearchAddressStructuredParams params) async {
    return await _repository.searchAddressStructured(
      addressNumber: params.addressNumber,
      street: params.street,
      locality: params.locality,
      region: params.region,
      country: params.country,
    );
  }
}

class SearchAddressStructuredParams {
  final String? addressNumber;
  final String? street;
  final String? locality;
  final String? region;
  final String? country;

  SearchAddressStructuredParams({
    this.addressNumber,
    this.street,
    this.locality,
    this.region,
    this.country,
  });
}
