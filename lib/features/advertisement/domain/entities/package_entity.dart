class PackageEntity {
  final String id;
  final String name;
  final String description;
  final int price;
  final int durationInDays;
  final int maxPostCount;
  final bool isActive;
  final DateTime createdAt;
  
  // Additional fields for purchased packages
  final String? partnerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? remainingPostCount;
  final String? paymentTransactionId;
  final String? status;
  final String? packageId;

  const PackageEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInDays,
    required this.maxPostCount,
    required this.isActive,
    required this.createdAt,
    this.partnerId,
    this.startDate,
    this.endDate,
    this.remainingPostCount,
    this.paymentTransactionId,
    this.status,
    this.packageId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackageEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.durationInDays == durationInDays &&
        other.maxPostCount == maxPostCount &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.partnerId == partnerId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.remainingPostCount == remainingPostCount &&
        other.paymentTransactionId == paymentTransactionId &&
        other.status == status &&
        other.packageId == packageId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        price.hashCode ^
        durationInDays.hashCode ^
        maxPostCount.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        partnerId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        remainingPostCount.hashCode ^
        paymentTransactionId.hashCode ^
        status.hashCode ^
        packageId.hashCode;
  }

  @override
  String toString() {
    return 'PackageEntity(id: $id, name: $name, description: $description, price: $price, durationInDays: $durationInDays, maxPostCount: $maxPostCount, isActive: $isActive, createdAt: $createdAt, partnerId: $partnerId, startDate: $startDate, endDate: $endDate, remainingPostCount: $remainingPostCount, paymentTransactionId: $paymentTransactionId, status: $status, packageId: $packageId)';
  }
}
