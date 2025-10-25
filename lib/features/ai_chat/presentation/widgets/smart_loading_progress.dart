import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
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
                width: 80 * _pulseAnimation.value,
                height: 80 * _pulseAnimation.value,
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
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_task,
                  color: Colors.white,
                  size: 40 * _pulseAnimation.value,
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
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
