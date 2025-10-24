class TransactionEntity {
  final String id;
  final String? gateway;
  final DateTime? transactionDate;
  final String? accountNumber;
  final String? subAccount;
  final double amountIn;
  final double amountOut;
  final double accumulated;
  final String? code;
  final String transactionContent;
  final String? referenceNumber;
  final String? body;
  final DateTime createdAt;
  final String packageId;
  final String userId;
  final String status;

  const TransactionEntity({
    required this.id,
    this.gateway,
    this.transactionDate,
    this.accountNumber,
    this.subAccount,
    required this.amountIn,
    required this.amountOut,
    required this.accumulated,
    this.code,
    required this.transactionContent,
    this.referenceNumber,
    this.body,
    required this.createdAt,
    required this.packageId,
    required this.userId,
    required this.status,
  });

  /// Get formatted amount for display
  String get formattedAmount {
    return '${amountIn.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    )} VNĐ';
  }

  /// Get status color for UI
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'cancel':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  /// Get status text in Vietnamese
  String get statusText {
    switch (status.toLowerCase()) {
      case 'success':
        return 'Thành công';
      case 'pending':
        return 'Đang xử lý';
      case 'cancel':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  /// Get formatted date for display
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  /// Get formatted time for display
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted transaction date if available
  String? get formattedTransactionDate {
    if (transactionDate == null) return null;
    return '${transactionDate!.day.toString().padLeft(2, '0')}/'
        '${transactionDate!.month.toString().padLeft(2, '0')}/'
        '${transactionDate!.year}';
  }

  /// Get formatted transaction time if available
  String? get formattedTransactionTime {
    if (transactionDate == null) return null;
    return '${transactionDate!.hour.toString().padLeft(2, '0')}:'
        '${transactionDate!.minute.toString().padLeft(2, '0')}';
  }

  /// Check if transaction is successful
  bool get isSuccess => status.toLowerCase() == 'success';

  /// Check if transaction is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if transaction is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancel';


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionEntity(id: $id, status: $status, amount: $formattedAmount)';
  }
}
