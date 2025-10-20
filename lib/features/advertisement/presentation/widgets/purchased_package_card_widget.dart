import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/package_entity.dart';

class PurchasedPackageCardWidget extends StatelessWidget {
  final PackageEntity package;
  final VoidCallback onTap;

  const PurchasedPackageCardWidget({
    super.key,
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: context.responsivePadding(
                horizontal: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 28.0,
                ),
                vertical: context.responsive(
                  verySmall: 16.0,
                  small: 18.0,
                  large: 20.0,
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: package.isActive 
                      ? [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.05),
                        ]
                      : [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: package.isActive 
                          ? const Color(0xFF6366F1).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.history_outlined,
                      size: context.responsiveIconSize(
                        verySmall: 18.0,
                        small: 20.0,
                        large: 22.0,
                      ),
                      color: package.isActive 
                          ? const Color(0xFF6366F1) 
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 18.0,
                              small: 20.0,
                              large: 22.0,
                            ),
                            fontWeight: FontWeight.w700,
                            color: package.isActive 
                                ? const Color(0xFF1E293B) 
                                : Colors.grey,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(
                          height: context.responsiveSpacing(
                            verySmall: 4.0,
                            small: 6.0,
                            large: 8.0,
                          ),
                        ),
                        Text(
                          'Gói đã mua',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 12.0,
                              small: 13.0,
                              large: 14.0,
                            ),
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: context.responsivePadding(
                      horizontal: context.responsive(
                        verySmall: 12.0,
                        small: 14.0,
                        large: 16.0,
                      ),
                      vertical: context.responsive(
                        verySmall: 6.0,
                        small: 8.0,
                        large: 10.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: package.isActive 
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Colors.grey,
                                Color(0xFF6B7280),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: package.isActive 
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      package.isActive ? 'Hoạt động' : 'Hết hạn',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 12.0,
                          small: 13.0,
                          large: 14.0,
                        ),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: context.responsivePadding(
                all: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 28.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Purchase Info
                  _buildInfoRow(
                    context,
                    Icons.article_outlined,
                    'Số bài đăng còn lại',
                    '${package.remainingPostCount ?? package.maxPostCount} bài',
                    const Color(0xFF6366F1),
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  
                  _buildInfoRow(
                    context,
                    Icons.schedule_outlined,
                    'Thời hạn còn lại',
                    _calculateRemainingDays(),
                    const Color(0xFF8B5CF6),
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_outlined,
                    'Ngày mua',
                    _formatDate(package.createdAt),
                    const Color(0xFF10B981),
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 16.0,
                      small: 20.0,
                      large: 24.0,
                    ),
                  ),
                  
                  // Price info
                  Container(
                    padding: context.responsivePadding(
                      all: context.responsive(
                        verySmall: 16.0,
                        small: 18.0,
                        large: 20.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payment_outlined,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: context.responsiveSpacing(
                            verySmall: 12.0,
                            small: 14.0,
                            large: 16.0,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã thanh toán',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 12.0,
                                    small: 13.0,
                                    large: 14.0,
                                  ),
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: context.responsiveSpacing(
                                  verySmall: 4.0,
                                  small: 6.0,
                                  large: 8.0,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                ).format(package.price),
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 18.0,
                                    small: 20.0,
                                    large: 22.0,
                                  ),
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF6366F1),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: context.responsivePadding(
                            horizontal: context.responsive(
                              verySmall: 12.0,
                              small: 14.0,
                              large: 16.0,
                            ),
                            vertical: context.responsive(
                              verySmall: 8.0,
                              small: 10.0,
                              large: 12.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Chi tiết',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 12.0,
                                small: 13.0,
                                large: 14.0,
                              ),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: context.responsiveIconSize(
              verySmall: 16.0,
              small: 18.0,
              large: 20.0,
            ),
            color: color,
          ),
        ),
        SizedBox(
          width: context.responsiveSpacing(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 14.0,
              small: 15.0,
              large: 16.0,
            ),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  String _calculateRemainingDays() {
    if (package.endDate != null) {
      final now = DateTime.now();
      final difference = package.endDate!.difference(now).inDays;
      
      if (difference <= 0) {
        return 'Đã hết hạn';
      } else if (difference == 1) {
        return '1 ngày';
      } else {
        return '$difference ngày';
      }
    } else {
      // Fallback to duration calculation if endDate is not available
      final now = DateTime.now();
      final endDate = package.createdAt.add(Duration(days: package.durationInDays));
      final difference = endDate.difference(now).inDays;
      
      if (difference <= 0) {
        return 'Đã hết hạn';
      } else if (difference == 1) {
        return '1 ngày';
      } else {
        return '$difference ngày';
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
