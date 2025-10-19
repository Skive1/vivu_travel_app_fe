import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.message,
    required super.bank,
    required super.transactionId,
    required super.content,
    required super.amount,
    required super.url,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      message: json['message'] as String,
      bank: json['bank'] as String,
      transactionId: json['transactionId'] as String,
      content: json['content'] as String,
      amount: (json['amount'] as num).toInt(),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bank': bank,
      'transactionId': transactionId,
      'content': content,
      'amount': amount,
      'url': url,
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      message: message,
      bank: bank,
      transactionId: transactionId,
      content: content,
      amount: amount,
      url: url,
    );
  }
}

class PaymentStatusModel extends PaymentStatusEntity {
  const PaymentStatusModel({
    required super.status,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      status: PaymentStatus.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }

  PaymentStatusEntity toEntity() {
    return PaymentStatusEntity(
      status: status,
    );
  }
}
