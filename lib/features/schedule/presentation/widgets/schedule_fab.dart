import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ScheduleFab extends StatefulWidget {
  const ScheduleFab({super.key});

  @override
  State<ScheduleFab> createState() => _ScheduleFabState();
}

class _ScheduleFabState extends State<ScheduleFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 120, // Above bottom navigation
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: () {
          _showAddScheduleModal(context);
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Thêm lịch trình mới',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Schedule type options
              const Text(
                'Loại hoạt động',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildScheduleTypeOption(
                      icon: Icons.explore,
                      title: 'Tham quan',
                      color: AppColors.primary,
                      onTap: () => _navigateToAddSchedule(context, 'tour'),
                    ),
                    _buildScheduleTypeOption(
                      icon: Icons.restaurant,
                      title: 'Ăn uống',
                      color: AppColors.accent,
                      onTap: () => _navigateToAddSchedule(context, 'dining'),
                    ),
                    _buildScheduleTypeOption(
                      icon: Icons.hotel,
                      title: 'Nghỉ dưỡng',
                      color: AppColors.secondary,
                      onTap: () => _navigateToAddSchedule(context, 'accommodation'),
                    ),
                    _buildScheduleTypeOption(
                      icon: Icons.shopping_bag,
                      title: 'Mua sắm',
                      color: AppColors.success,
                      onTap: () => _navigateToAddSchedule(context, 'shopping'),
                    ),
                    _buildScheduleTypeOption(
                      icon: Icons.flight,
                      title: 'Di chuyển',
                      color: AppColors.info,
                      onTap: () => _navigateToAddSchedule(context, 'transport'),
                    ),
                    _buildScheduleTypeOption(
                      icon: Icons.event,
                      title: 'Khác',
                      color: AppColors.textSecondary,
                      onTap: () => _navigateToAddSchedule(context, 'other'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleTypeOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddSchedule(BuildContext context, String type) {
    Navigator.pop(context); // Close modal
    
    // Show snackbar for demo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm lịch trình $type'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
