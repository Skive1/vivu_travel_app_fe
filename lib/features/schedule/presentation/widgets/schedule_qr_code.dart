import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class ScheduleQrCode extends StatelessWidget {
  final String sharedCode;

  const ScheduleQrCode({
    Key? key,
    required this.sharedCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.qr_code_2,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Mã QR chia sẻ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Quét mã QR này để tham gia lịch trình',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: QrImageView(
              data: sharedCode,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              sharedCode,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
