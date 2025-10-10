import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OptimizedSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const OptimizedSkeleton({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ScheduleListSkeleton extends StatelessWidget {
  final int itemCount;

  const ScheduleListSkeleton({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title skeleton
              Row(
                children: [
                  Expanded(
                    child: OptimizedSkeleton(
                      height: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OptimizedSkeleton(
                    width: 80,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Location skeleton
              Row(
                children: [
                  OptimizedSkeleton(
                    width: 16,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OptimizedSkeleton(
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date skeleton
              Row(
                children: [
                  OptimizedSkeleton(
                    width: 16,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OptimizedSkeleton(
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Participants skeleton
              Row(
                children: [
                  OptimizedSkeleton(
                    width: 16,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  OptimizedSkeleton(
                    width: 120,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const Spacer(),
                  OptimizedSkeleton(
                    width: 60,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Button skeleton
              OptimizedSkeleton(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ActivityListSkeleton extends StatelessWidget {
  final int itemCount;

  const ActivityListSkeleton({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final isLast = index == itemCount - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                OptimizedSkeleton(
                  width: 12,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time skeleton
                    OptimizedSkeleton(
                      width: 80,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    
                    // Title skeleton
                    OptimizedSkeleton(
                      width: double.infinity,
                      height: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    
                    // Description skeleton
                    OptimizedSkeleton(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    OptimizedSkeleton(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
