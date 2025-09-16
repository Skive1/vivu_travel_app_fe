import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'profile_avatar.dart';
import 'profile_user_info.dart';
import 'profile_stats_section.dart';
import 'profile_menu_section.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ProfileContent(topPadding: safePadding.top),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final double topPadding;
  
  const ProfileContent({
    super.key,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Column(
      children: [
        // Top safe area spacer
        SizedBox(height: topPadding),
        
        // Header với back button và title
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFF0F0F0),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        
        // Content body
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                  child: const Column(
                    children: [
                      // Avatar
                      ProfileAvatar(),
                      SizedBox(height: 16),
                      // User Info
                      ProfileUserInfo(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Statistics Cards
                const ProfileStatsSection(),
                
                const SizedBox(height: 30),
                
                // Menu Items
                const ProfileMenuSection(),
                
                // Bottom safe area spacer
                SizedBox(height: bottomPadding + 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
