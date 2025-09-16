import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all categories
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
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryItem(
                icon: Icons.beach_access,
                label: 'Biển',
                color: const Color(0xFF4FC3F7),
                onTap: () => _handleCategoryTap('Biển'),
              ),
              _buildCategoryItem(
                icon: Icons.landscape,
                label: 'Núi',
                color: const Color(0xFF66BB6A),
                onTap: () => _handleCategoryTap('Núi'),
              ),
              _buildCategoryItem(
                icon: Icons.location_city,
                label: 'Thành phố',
                color: const Color(0xFFFF7043),
                onTap: () => _handleCategoryTap('Thành phố'),
              ),
              _buildCategoryItem(
                icon: Icons.temple_buddhist,
                label: 'Văn hóa',
                color: const Color(0xFFAB47BC),
                onTap: () => _handleCategoryTap('Văn hóa'),
              ),
              _buildCategoryItem(
                icon: Icons.local_dining,
                label: 'Ẩm thực',
                color: const Color(0xFFEF5350),
                onTap: () => _handleCategoryTap('Ẩm thực'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryTap(String category) {
    // Handle category selection
    print('Selected category: $category');
  }
}