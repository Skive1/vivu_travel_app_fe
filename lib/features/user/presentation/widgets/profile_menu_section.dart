import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          MenuRow(
            icon: Icons.person_outline,
            title: 'Profile',
          ),
          MenuRow(
            icon: Icons.bookmark_outline,
            title: 'Bookmarked',
          ),
          MenuRow(
            icon: Icons.travel_explore_outlined,
            title: 'Previous Trips',
          ),
          MenuRow(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
          MenuRow(
            icon: Icons.info_outline,
            title: 'Version',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;

  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(16),
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFF0F0F0),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}