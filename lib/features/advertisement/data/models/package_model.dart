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
    super.partnerId,
    super.startDate,
    super.endDate,
    super.remainingPostCount,
    super.paymentTransactionId,
    super.status,
    super.packageId,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final startDateStr = (json['startDate'] ?? json['start_date'])?.toString();
    final endDateStr = (json['endDate'] ?? json['end_date'])?.toString();
    final startDate = DateTime.tryParse(startDateStr ?? '');
    final endDate = DateTime.tryParse(endDateStr ?? '');
    final computedDuration = (startDate != null && endDate != null)
        ? endDate.difference(startDate).inDays
        : null;
    final remainingPostCount = json['remainingPostCount'];
    return PackageModel(
      id: (json['id'] ?? json['packageId'] ?? '').toString(),
      name: (json['name'] ?? json['packageName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toInt()
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      durationInDays: (json['durationInDays'] is num)
              ? (json['durationInDays'] as num).toInt()
              : (computedDuration ?? int.tryParse(json['durationInDays']?.toString() ?? '0') ?? 0),
      maxPostCount: (json['maxPostCount'] is num)
              ? (json['maxPostCount'] as num).toInt()
              : (remainingPostCount is num
                  ? remainingPostCount.toInt()
                  : int.tryParse(json['maxPostCount']?.toString() ?? '0') ?? 0),
      isActive: json['isActive'] == true ||
          json['isActive'] == 'true' ||
          (json['status']?.toString().toLowerCase() == 'active'),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['created_date'] ?? '').toString()) ?? DateTime.now(),
      // Additional fields for purchased packages
      partnerId: json['partnerId']?.toString(),
      startDate: startDate,
      endDate: endDate,
      remainingPostCount: remainingPostCount is num ? remainingPostCount.toInt() : null,
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      status: json['status']?.toString(),
      packageId: json['packageId']?.toString(),
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
      'partnerId': partnerId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'remainingPostCount': remainingPostCount,
      'paymentTransactionId': paymentTransactionId,
      'status': status,
      'packageId': packageId,
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
      partnerId: partnerId,
      startDate: startDate,
      endDate: endDate,
      remainingPostCount: remainingPostCount,
      paymentTransactionId: paymentTransactionId,
      status: status,
      packageId: packageId,
    );
  }
}
