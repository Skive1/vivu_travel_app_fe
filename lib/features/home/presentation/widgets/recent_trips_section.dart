import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RecentTripsSection extends StatelessWidget {
  const RecentTripsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chuyến đi gần đây',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to trip history
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildTripItem(
              destination: 'Đà Nẵng',
              date: '15 - 18 Tháng 12, 2024',
              status: 'Đã hoàn thành',
              statusColor: AppColors.success,
              image: 'assets/images/trip_1.jpg',
              onTap: () => _handleTripTap('Đà Nẵng'),
            ),
            const SizedBox(height: 12),
            _buildTripItem(
              destination: 'Nha Trang',
              date: '22 - 25 Tháng 12, 2024',
              status: 'Sắp tới',
              statusColor: AppColors.warning,
              image: 'assets/images/trip_2.jpg',
              onTap: () => _handleTripTap('Nha Trang'),
            ),
            const SizedBox(height: 12),
            _buildTripItem(
              destination: 'Phú Quốc',
              date: '5 - 10 Tháng 1, 2025',
              status: 'Đã đặt',
              statusColor: AppColors.info,
              image: 'assets/images/trip_3.jpg',
              onTap: () => _handleTripTap('Phú Quốc'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripItem({
    required String destination,
    required String date,
    required String status,
    required Color statusColor,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trip image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.7),
                    AppColors.accent.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Trip details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTripTap(String destination) {
    // Handle trip selection
    print('Selected trip: $destination');
  }
}