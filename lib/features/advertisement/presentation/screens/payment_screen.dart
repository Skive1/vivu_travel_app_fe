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

  @override
  void initState() {
    super.initState();
    _createPayment();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
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
  }

  void _stopStatusChecking() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: BlocConsumer<AdvertisementBloc, AdvertisementState>(
        listener: (context, state) {
          if (state is PaymentCreated) {
            setState(() {
              _payment = state.payment;
            });
            _startStatusChecking(state.payment.transactionId);
          } else if (state is PaymentStatusChecked) {
            if (state.status.status.name == 'success') {
              _stopStatusChecking();
              _showSuccessDialog();
            } else if (state.status.status.name == 'failed') {
              _stopStatusChecking();
              _showFailureDialog();
            }
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
          
          // QR Code
          _buildQRCode(),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 24.0,
              small: 28.0,
              large: 32.0,
            ),
          ),
          
          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildPackageInfo() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 16.0,
          small: 18.0,
          large: 20.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.responsive(
              verySmall: 4.0,
              small: 6.0,
              large: 8.0,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin gói dịch vụ',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 16.0,
                small: 17.0,
                large: 18.0,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
                verySmall: 18.0,
                small: 20.0,
                large: 22.0,
              ),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
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
          verySmall: 16.0,
          small: 18.0,
          large: 20.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.responsive(
              verySmall: 4.0,
              small: 6.0,
              large: 8.0,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 16.0,
                small: 17.0,
                large: 18.0,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.responsive(
              verySmall: 4.0,
              small: 6.0,
              large: 8.0,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 16.0,
                small: 17.0,
                large: 18.0,
              ),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          
          QrImageView(
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
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius(
                  verySmall: 8.0,
                  small: 10.0,
                  large: 12.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: context.responsiveIconSize(
                    verySmall: 16.0,
                    small: 18.0,
                    large: 20.0,
                  ),
                  color: AppColors.primary,
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
                    'Đang kiểm tra trạng thái thanh toán...',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 12.0,
                        small: 13.0,
                        large: 14.0,
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                ),
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
                    strokeWidth: 2.0,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: context.responsivePadding(
        all: context.responsive(
          verySmall: 16.0,
          small: 18.0,
          large: 20.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: context.responsiveIconSize(
                  verySmall: 18.0,
                  small: 20.0,
                  large: 22.0,
                ),
                color: Colors.blue,
              ),
              SizedBox(
                width: context.responsiveSpacing(
                  verySmall: 8.0,
                  small: 10.0,
                  large: 12.0,
                ),
              ),
              Text(
                'Hướng dẫn thanh toán',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 16.0,
                    small: 17.0,
                    large: 18.0,
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(
                context.responsiveBorderRadius(
                  verySmall: 10.0,
                  small: 11.0,
                  large: 12.0,
                ),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 12.0,
                    small: 13.0,
                    large: 14.0,
                  ),
                  fontWeight: FontWeight.bold,
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
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                color: AppColors.textPrimary,
                height: 1.4,
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
        Navigator.of(context).pop(); // Go back to packages list
      },
    );
  }

  void _showFailureDialog() {
    DialogUtils.showErrorDialog(
      context: context,
      title: 'Thanh toán thất bại',
      message: 'Giao dịch thanh toán không thành công. Vui lòng thử lại.',
      buttonText: 'Thử lại',
      onPressed: () {
        Navigator.of(context).pop();
        _createPayment();
      },
    );
  }
}
