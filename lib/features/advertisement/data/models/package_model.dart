import '../../domain/entities/package_entity.dart';

class PackageModel extends PackageEntity {
  const PackageModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.durationInDays,
    required super.maxPostCount,
    required super.isActive,
    required super.createdAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      durationInDays: (json['durationInDays'] as num).toInt(),
      maxPostCount: (json['maxPostCount'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationInDays': durationInDays,
      'maxPostCount': maxPostCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      durationInDays: durationInDays,
      maxPostCount: maxPostCount,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
