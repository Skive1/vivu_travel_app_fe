import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class SmartLoadingProgress extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onCancel;

  const SmartLoadingProgress({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onCancel,
  }) : super(key: key);

  @override
  State<SmartLoadingProgress> createState() => _SmartLoadingProgressState();
}

class _SmartLoadingProgressState extends State<SmartLoadingProgress>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  double _currentProgress = 0.0;
  String _currentStatus = 'Đang khởi tạo...';

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation with error handling
    try {
      _pulseController.repeat(reverse: true);
    } catch (e) {
      // Handle animation error gracefully
    }
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    // Simulate realistic API progress
    _updateProgress(0.1, 'Đang kết nối với server...');
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _updateProgress(0.3, 'Đang xử lý dữ liệu...');
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _updateProgress(0.6, 'Đang tạo hoạt động...');
      }
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _updateProgress(0.8, 'Đang lưu vào database...');
      }
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _updateProgress(1.0, 'Hoàn thành!');
      }
    });
  }

  void _updateProgress(double progress, String status) {
    if (mounted && _progressController.isAnimating == false) {
      setState(() {
        _currentProgress = progress;
        _currentStatus = status;
      });
      _progressController.animateTo(progress);
    }
  }

  @override
  void dispose() {
    _pulseController.stop();
    _progressController.stop();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.responsivePadding(all: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 16, small: 18, large: 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: context.responsiveElevation(verySmall: 16, small: 18, large: 20),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: context.responsiveIconSize(verySmall: 70, small: 75, large: 80) * _pulseAnimation.value,
                height: context.responsiveIconSize(verySmall: 70, small: 75, large: 80) * _pulseAnimation.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: context.responsiveElevation(verySmall: 16, small: 18, large: 20),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_task,
                  color: Colors.white,
                  size: context.responsiveIconSize(verySmall: 35, small: 37, large: 40) * _pulseAnimation.value,
                ),
              );
            },
          ),
          
          SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
          
          // Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: context.responsiveFontSize(verySmall: 18, small: 20, large: 22),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          
          // Subtitle
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: context.responsiveSpacing(verySmall: 28, small: 30, large: 32)),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress percentage and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_currentProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  _currentStatus,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cancel button
          if (widget.onCancel != null)
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Hủy'),
            ),
        ],
      ),
    );
  }
}
