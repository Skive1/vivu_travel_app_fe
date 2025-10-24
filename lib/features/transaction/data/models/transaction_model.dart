import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.gateway,
    super.transactionDate,
    super.accountNumber,
    super.subAccount,
    required super.amountIn,
    required super.amountOut,
    required super.accumulated,
    super.code,
    required super.transactionContent,
    super.referenceNumber,
    super.body,
    required super.createdAt,
    required super.packageId,
    required super.userId,
    required super.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      gateway: json['gateway'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'] as String)
          : null,
      accountNumber: json['accountNumber'] as String?,
      subAccount: json['subAccount'] as String?,
      amountIn: (json['amountIn'] as num).toDouble(),
      amountOut: (json['amountOut'] as num).toDouble(),
      accumulated: (json['accumulated'] as num).toDouble(),
      code: json['code'] as String?,
      transactionContent: json['transactionContent'] as String,
      referenceNumber: json['referenceNumber'] as String?,
      body: json['body'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      packageId: json['packageId'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gateway': gateway,
      'transactionDate': transactionDate?.toIso8601String(),
      'accountNumber': accountNumber,
      'subAccount': subAccount,
      'amountIn': amountIn,
      'amountOut': amountOut,
      'accumulated': accumulated,
      'code': code,
      'transactionContent': transactionContent,
      'referenceNumber': referenceNumber,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'packageId': packageId,
      'userId': userId,
      'status': status,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      gateway: entity.gateway,
      transactionDate: entity.transactionDate,
      accountNumber: entity.accountNumber,
      subAccount: entity.subAccount,
      amountIn: entity.amountIn,
      amountOut: entity.amountOut,
      accumulated: entity.accumulated,
      code: entity.code,
      transactionContent: entity.transactionContent,
      referenceNumber: entity.referenceNumber,
      body: entity.body,
      createdAt: entity.createdAt,
      packageId: entity.packageId,
      userId: entity.userId,
      status: entity.status,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      gateway: gateway,
      transactionDate: transactionDate,
      accountNumber: accountNumber,
      subAccount: subAccount,
      amountIn: amountIn,
      amountOut: amountOut,
      accumulated: accumulated,
      code: code,
      transactionContent: transactionContent,
      referenceNumber: referenceNumber,
      body: body,
      createdAt: createdAt,
      packageId: packageId,
      userId: userId,
      status: status,
    );
  }
}
