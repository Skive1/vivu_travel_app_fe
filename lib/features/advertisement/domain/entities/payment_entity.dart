enum PaymentStatus {
  pending('Pending'),
  success('Success'),
  failed('Failed'),
  cancelled('Cancelled');

  const PaymentStatus(this.displayName);
  final String displayName;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentEntity {
  final String message;
  final String bank;
  final String transactionId;
  final String content;
  final int amount;
  final String url;

  const PaymentEntity({
    required this.message,
    required this.bank,
    required this.transactionId,
    required this.content,
    required this.amount,
    required this.url,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentEntity &&
        other.message == message &&
        other.bank == bank &&
        other.transactionId == transactionId &&
        other.content == content &&
        other.amount == amount &&
        other.url == url;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        bank.hashCode ^
        transactionId.hashCode ^
        content.hashCode ^
        amount.hashCode ^
        url.hashCode;
  }

  @override
  String toString() {
    return 'PaymentEntity(message: $message, bank: $bank, transactionId: $transactionId, content: $content, amount: $amount, url: $url)';
  }
}

class PaymentStatusEntity {
  final PaymentStatus status;

  const PaymentStatusEntity({
    required this.status,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentStatusEntity && other.status == status;
  }

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'PaymentStatusEntity(status: $status)';
}
