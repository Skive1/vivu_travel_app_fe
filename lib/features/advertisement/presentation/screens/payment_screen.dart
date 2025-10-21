import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/package_entity.dart';

class PaymentScreen extends StatefulWidget {
  final PackageEntity package;

  const PaymentScreen({
    super.key,
    required this.package,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentEntity? _payment;
  Timer? _statusTimer;
  Timer? _cancelTimer;
  Timer? _countdownTimer;
  PaymentStatus? _currentStatus;
  int _remainingSeconds = 0; // countdown mm:ss

  @override
  void initState() {
    super.initState();
    _createPayment();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _cancelTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _createPayment() {
    context.read<AdvertisementBloc>().add(
      CreatePayment(
        packageId: widget.package.id,
        amount: widget.package.price,
      ),
    );
  }

  void _startStatusChecking(String transactionId) {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        context.read<AdvertisementBloc>().add(
          CheckPaymentStatus(transactionId),
        );
      }
    });

    // Start cancel timer after 5 minutes
    _cancelTimer = Timer(const Duration(minutes: 5), () {
      if (mounted && _currentStatus == PaymentStatus.pending) {
        context.read<AdvertisementBloc>().add(
          CancelPayment(transactionId),
        );
      }
    });

    // Start visible countdown (5 minutes)
    setState(() {
      _remainingSeconds = 5 * 60;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        t.cancel();
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _stopStatusChecking() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _cancelTimer?.cancel();
    _cancelTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Cancel pending transaction before leaving
        if (_payment != null && _currentStatus == PaymentStatus.pending) {
          context.read<AdvertisementBloc>().add(CancelPayment(_payment!.transactionId));
          // Wait for cancellation result (handled in listener)
          return false;
        }
        // Not pending: simply close
        Navigator.of(context).pop(false);
        return false;
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Thanh toán',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 18.0,
              small: 20.0,
              large: 22.0,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if (_payment != null && _currentStatus == PaymentStatus.pending) {
              context.read<AdvertisementBloc>().add(CancelPayment(_payment!.transactionId));
              // Wait for PaymentCancelled listener to handle pop + reload
              return;
            }
            Navigator.of(context).pop(false);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: BlocConsumer<AdvertisementBloc, AdvertisementState>(
        listener: (context, state) {
          if (state is PaymentCreated) {
            setState(() {
              _payment = state.payment;
              _currentStatus = PaymentStatus.pending;
            });
            _startStatusChecking(state.payment.transactionId);
          } else if (state is PaymentStatusChecked) {
            setState(() {
              _currentStatus = state.status.status;
            });
            if (state.status.status.name == 'success') {
              _stopStatusChecking();
              _showSuccessDialog();
            } else if (state.status.status.name == 'failed') {
              _stopStatusChecking();
              _showFailureDialog();
            }
          } else if (state is PaymentCancelled) {
            setState(() {
              _currentStatus = state.status.status;
            });
            _stopStatusChecking();
            _showCancelledDialog();
          } else if (state is AdvertisementError) {
            DialogUtils.showErrorDialog(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdvertisementLoading && _payment == null;

          return Stack(
            children: [
              if (_payment != null)
                _buildPaymentContent()
              else if (isLoading)
                _buildLoadingContent()
              else
                _buildErrorContent(),
              LoadingOverlay(isLoading: isLoading),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildPaymentContent() {
    return SingleChildScrollView(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 16.0,
          small: 20.0,
          large: 24.0,
        ),
      ),
      child: Column(
        children: [
          // Package Info
          _buildPackageInfo(),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 24.0,
              small: 28.0,
              large: 32.0,
            ),
          ),
          
          // Payment Info
          _buildPaymentInfo(),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 24.0,
              small: 28.0,
              large: 32.0,
            ),
          ),
          
          // QR Code (only show while pending)
          if (_currentStatus == PaymentStatus.pending)
          _buildQRCode(),
          
          // Show cancelled status if payment is cancelled
          if (_currentStatus == PaymentStatus.cancel)
            _buildCancelledStatus(),

          // Show success status if payment succeeded
          if (_currentStatus == PaymentStatus.success)
            _buildSuccessStatus(),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 24.0,
              small: 28.0,
              large: 32.0,
            ),
          ),
          
          // Instructions (only show while pending)
          if (_currentStatus == PaymentStatus.pending)
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildPackageInfo() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard_outlined,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thông tin gói dịch vụ',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          
          Text(
            widget.package.name,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 20.0,
                small: 22.0,
                large: 24.0,
              ),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6366F1),
              letterSpacing: -0.5,
            ),
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 8.0,
              small: 10.0,
              large: 12.0,
            ),
          ),
          
          Text(
            widget.package.description,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_outlined,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thông tin thanh toán',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          
          _buildInfoRow('Số tiền', '₫${_payment!.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
          _buildInfoRow('Ngân hàng', _payment!.bank),
          _buildInfoRow('Nội dung', _payment!.content),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          verySmall: 8.0,
          small: 10.0,
          large: 12.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.responsive(
              verySmall: 80.0,
              small: 90.0,
              large: 100.0,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 24.0,
          small: 28.0,
          large: 32.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_outlined,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quét mã QR',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              ),
              const SizedBox(width: 8),
              if (_currentStatus == PaymentStatus.pending)
                _buildCountdownChip(),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          
          // Prefer server-provided QR image URL; fallback to generating from data
          _payment!.url.startsWith('http')
              ? SizedBox(
                  width: context.responsive(
                    verySmall: 200.0,
                    small: 220.0,
                    large: 240.0,
                  ),
                  height: context.responsive(
                    verySmall: 200.0,
                    small: 220.0,
                    large: 240.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      _payment!.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return QrImageView(
                          data: _payment!.url,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        );
                      },
                    ),
                  ),
                )
              : QrImageView(
                  data: _payment!.url,
                  version: QrVersions.auto,
                  size: context.responsive(
                    verySmall: 200.0,
                    small: 220.0,
                    large: 240.0,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          
          Container(
            padding: context.responsivePadding(
              all: context.responsive(
                verySmall: 16.0,
                small: 18.0,
                large: 20.0,
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.1),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sync_outlined,
                    size: context.responsiveIconSize(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                    color: const Color(0xFF6366F1),
                  ),
                ),
                SizedBox(
                  width: context.responsiveSpacing(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                ),
                Expanded(child: _buildStatusAndCountdownText()),
                SizedBox(
                  width: context.responsive(
                    verySmall: 16.0,
                    small: 18.0,
                    large: 20.0,
                  ),
                  height: context.responsive(
                    verySmall: 16.0,
                    small: 18.0,
                    large: 20.0,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small chip with remaining time mm:ss
  Widget _buildCountdownChip() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF94A3B8).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF334155)),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Status text with countdown details
  Widget _buildStatusAndCountdownText() {
    String text = 'Đang kiểm tra trạng thái thanh toán...';
    if (_currentStatus == PaymentStatus.pending && _remainingSeconds > 0) {
      final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
      final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
      text = 'Vui lòng thanh toán trong $m:$s';
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: context.responsiveFontSize(
          verySmall: 13.0,
          small: 14.0,
          large: 15.0,
        ),
        color: const Color(0xFF6366F1),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.08),
            const Color(0xFF1D4ED8).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: context.responsiveIconSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(
                width: context.responsiveSpacing(
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
              ),
              Text(
                'Hướng dẫn thanh toán',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          
          _buildInstructionStep(
            '1',
            'Mở ứng dụng ngân hàng trên điện thoại',
          ),
          
          _buildInstructionStep(
            '2',
            'Chọn chức năng "Quét mã QR"',
          ),
          
          _buildInstructionStep(
            '3',
            'Quét mã QR ở trên để thanh toán',
          ),
          
          _buildInstructionStep(
            '4',
            'Xác nhận thông tin và hoàn tất thanh toán',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          verySmall: 8.0,
          small: 10.0,
          large: 12.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.responsive(
              verySmall: 20.0,
              small: 22.0,
              large: 24.0,
            ),
            height: context.responsive(
              verySmall: 20.0,
              small: 22.0,
              large: 24.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6),
                  const Color(0xFF1D4ED8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 13.0,
                    small: 14.0,
                    large: 15.0,
                  ),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(
            width: context.responsiveSpacing(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 15.0,
                  small: 16.0,
                  large: 17.0,
                ),
                color: const Color(0xFF374151),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tạo giao dịch thanh toán...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Không thể tạo giao dịch thanh toán',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createPayment,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    DialogUtils.showSuccessDialog(
      context: context,
      title: 'Thanh toán thành công!',
      message: 'Gói dịch vụ đã được kích hoạt. Bạn có thể bắt đầu tạo bài đăng.',
      buttonText: 'Đóng',
      onPressed: () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(true); // Return success to packages list
      },
    );
  }

  void _showFailureDialog() {
    if (!mounted) return;
    DialogUtils.showErrorDialog(
      context: context,
      title: 'Thanh toán thất bại',
      message: 'Giao dịch thanh toán không thành công.',
      buttonText: 'Đóng',
    ).whenComplete(() {
      if (!mounted) return;
      // Ensure packages list refreshes when returning
      context.read<AdvertisementBloc>().add(const RefreshPackages());
      Navigator.of(context).pop(false);
    });
  }

  void _showCancelledDialog() {
    if (!mounted) return;
    DialogUtils.showErrorDialog(
      context: context,
      title: 'Giao dịch đã hủy',
      message: 'Giao dịch thanh toán đã được hủy do quá thời gian chờ (5 phút).',
      buttonText: 'Đóng',
    ).whenComplete(() {
      if (!mounted) return;
      // Ensure packages list refreshes when returning (force GetAll)
      context.read<AdvertisementBloc>().add(const LoadAllPackages());
      Navigator.of(context).pop(false);
    });
  }

  Widget _buildCancelledStatus() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 24.0,
          small: 28.0,
          large: 32.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Giao dịch đã hủy',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          
          Container(
            padding: context.responsivePadding(
              all: context.responsive(
                verySmall: 16.0,
                small: 18.0,
                large: 20.0,
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.1),
                  const Color(0xFFDC2626).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_outlined,
                    size: context.responsiveIconSize(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                    color: const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(
                  width: context.responsiveSpacing(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Giao dịch đã được hủy do quá thời gian chờ (5 phút)',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 13.0,
                        small: 14.0,
                        large: 15.0,
                      ),
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStatus() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 24.0,
          small: 28.0,
          large: 32.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Thanh toán thành công',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          
          Container(
            padding: context.responsivePadding(
              all: context.responsive(
                verySmall: 16.0,
                small: 18.0,
                large: 20.0,
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.1),
                  const Color(0xFF34D399).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.celebration_outlined,
                    size: context.responsiveIconSize(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                    color: const Color(0xFF10B981),
                  ),
                ),
                SizedBox(
                  width: context.responsiveSpacing(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Cảm ơn bạn! Gói dịch vụ đã được kích hoạt.',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 13.0,
                        small: 14.0,
                        large: 15.0,
                      ),
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
