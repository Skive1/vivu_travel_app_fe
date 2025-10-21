class MapboxGeocodingResponse {
  final String type;
  final List<Feature> features;

  MapboxGeocodingResponse({
    required this.type,
    required this.features,
  });

  factory MapboxGeocodingResponse.fromJson(Map<String, dynamic> json) {
    return MapboxGeocodingResponse(
      type: json['type'] as String,
      features: (json['features'] as List)
          .map((feature) => Feature.fromJson(feature as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Feature {
  final String type;
  final Geometry geometry;
  final Properties properties;

  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      type: json['type'] as String,
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      properties: Properties.fromJson(json['properties'] as Map<String, dynamic>),
    );
  }
}

class Geometry {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List).cast<double>(),
    );
  }
}

class Properties {
  final String? mapboxId;
  final String? featureType;
  final String? fullAddress;
  final String? name;
  final String? namePreferred;
  final String? placeFormatted;
  final MapboxCoordinates? coordinates;
  final MapboxContext? context;

  Properties({
    this.mapboxId,
    this.featureType,
    this.fullAddress,
    this.name,
    this.namePreferred,
    this.placeFormatted,
    this.coordinates,
    this.context,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      mapboxId: json['mapbox_id'] as String?,
      featureType: json['feature_type'] as String?,
      fullAddress: json['full_address'] as String?,
      name: json['name'] as String?,
      namePreferred: json['name_preferred'] as String?,
      placeFormatted: json['place_formatted'] as String?,
      coordinates: json['coordinates'] != null 
          ? MapboxCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      context: json['context'] != null
          ? MapboxContext.fromJson(json['context'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MapboxCoordinates {
  final double longitude;
  final double latitude;
  final String? accuracy;

  MapboxCoordinates({
    required this.longitude,
    required this.latitude,
    this.accuracy,
  });

  factory MapboxCoordinates.fromJson(Map<String, dynamic> json) {
    return MapboxCoordinates(
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      accuracy: json['accuracy'] as String?,
    );
  }
}

class MapboxContext {
  final MapboxAddress? address;
  final MapboxStreet? street;
  final MapboxNeighborhood? neighborhood;
  final MapboxPostcode? postcode;
  final MapboxLocality? locality;
  final MapboxPlace? place;
  final MapboxRegion? region;
  final MapboxCountry? country;

  MapboxContext({
    this.address,
    this.street,
    this.neighborhood,
    this.postcode,
    this.locality,
    this.place,
    this.region,
    this.country,
  });

  factory MapboxContext.fromJson(Map<String, dynamic> json) {
    return MapboxContext(
      address: json['address'] != null
          ? MapboxAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      street: json['street'] != null
          ? MapboxStreet.fromJson(json['street'] as Map<String, dynamic>)
          : null,
      neighborhood: json['neighborhood'] != null
          ? MapboxNeighborhood.fromJson(json['neighborhood'] as Map<String, dynamic>)
          : null,
      postcode: json['postcode'] != null
          ? MapboxPostcode.fromJson(json['postcode'] as Map<String, dynamic>)
          : null,
      locality: json['locality'] != null
          ? MapboxLocality.fromJson(json['locality'] as Map<String, dynamic>)
          : null,
      place: json['place'] != null
          ? MapboxPlace.fromJson(json['place'] as Map<String, dynamic>)
          : null,
      region: json['region'] != null
          ? MapboxRegion.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      country: json['country'] != null
          ? MapboxCountry.fromJson(json['country'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MapboxAddress {
  final String? mapboxId;
  final String? addressNumber;
  final String? streetName;
  final String? name;

  MapboxAddress({
    this.mapboxId,
    this.addressNumber,
    this.streetName,
    this.name,
  });

  factory MapboxAddress.fromJson(Map<String, dynamic> json) {
    return MapboxAddress(
      mapboxId: json['mapbox_id'] as String?,
      addressNumber: json['address_number'] as String?,
      streetName: json['street_name'] as String?,
      name: json['name'] as String?,
    );
  }
}

class MapboxStreet {
  final String? mapboxId;
  final String? name;

  MapboxStreet({
    this.mapboxId,
    this.name,
  });

  factory MapboxStreet.fromJson(Map<String, dynamic> json) {
    return MapboxStreet(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
    );
  }
}

class MapboxNeighborhood {
  final String? mapboxId;
  final String? name;
  final String? wikidataId;

  MapboxNeighborhood({
    this.mapboxId,
    this.name,
    this.wikidataId,
  });

  factory MapboxNeighborhood.fromJson(Map<String, dynamic> json) {
    return MapboxNeighborhood(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
      wikidataId: json['wikidata_id'] as String?,
    );
  }
}

class MapboxPostcode {
  final String? mapboxId;
  final String? name;

  MapboxPostcode({
    this.mapboxId,
    this.name,
  });

  factory MapboxPostcode.fromJson(Map<String, dynamic> json) {
    return MapboxPostcode(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
    );
  }
}

class MapboxLocality {
  final String? mapboxId;
  final String? name;
  final String? wikidataId;

  MapboxLocality({
    this.mapboxId,
    this.name,
    this.wikidataId,
  });

  factory MapboxLocality.fromJson(Map<String, dynamic> json) {
    return MapboxLocality(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
      wikidataId: json['wikidata_id'] as String?,
    );
  }
}

class MapboxPlace {
  final String? mapboxId;
  final String? name;
  final String? wikidataId;
  final String? shortCode;

  MapboxPlace({
    this.mapboxId,
    this.name,
    this.wikidataId,
    this.shortCode,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    return MapboxPlace(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
      wikidataId: json['wikidata_id'] as String?,
      shortCode: json['short_code'] as String?,
    );
  }
}

class MapboxRegion {
  final String? mapboxId;
  final String? name;
  final String? wikidataId;
  final String? regionCode;
  final String? regionCodeFull;

  MapboxRegion({
    this.mapboxId,
    this.name,
    this.wikidataId,
    this.regionCode,
    this.regionCodeFull,
  });

  factory MapboxRegion.fromJson(Map<String, dynamic> json) {
    return MapboxRegion(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
      wikidataId: json['wikidata_id'] as String?,
      regionCode: json['region_code'] as String?,
      regionCodeFull: json['region_code_full'] as String?,
    );
  }
}

class MapboxCountry {
  final String? mapboxId;
  final String? name;
  final String? wikidataId;
  final String? countryCode;
  final String? countryCodeAlpha3;

  MapboxCountry({
    this.mapboxId,
    this.name,
    this.wikidataId,
    this.countryCode,
    this.countryCodeAlpha3,
  });

  factory MapboxCountry.fromJson(Map<String, dynamic> json) {
    return MapboxCountry(
      mapboxId: json['mapbox_id'] as String?,
      name: json['name'] as String?,
      wikidataId: json['wikidata_id'] as String?,
      countryCode: json['country_code'] as String?,
      countryCodeAlpha3: json['country_code_alpha_3'] as String?,
    );
  }
}
