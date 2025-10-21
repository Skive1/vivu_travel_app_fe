import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class ExploreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final VoidCallback onRefresh;

  const ExploreAppBar({
    super.key,
    required this.tabController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar content
            Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  verySmall: 16.0,
                  small: 20.0,
                  large: 24.0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Khám phá',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 20.0,
                        small: 22.0,
                        large: 24.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      size: context.responsiveIconSize(
                        verySmall: 20.0,
                        small: 22.0,
                        large: 24.0,
                      ),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // TabBar
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3.0,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                fontWeight: FontWeight.w500,
              ),
              tabs: tabController.length == 3
                  ? const [
                      Tab(text: 'Bài đăng'),
                      Tab(text: 'Gói dịch vụ'),
                      Tab(text: 'Gói của bạn'),
                    ]
                  : const [
                      Tab(text: 'Bài đăng'),
                      Tab(text: 'Gói dịch vụ'),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(105.0); // 56 (AppBar) + 49 (TabBar)
}
