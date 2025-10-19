import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/post_entity.dart';
import 'post_media_widget.dart';
import 'post_status_chip.dart';

class PostCardWidget extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            context.responsiveBorderRadius(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.responsive(
                verySmall: 4.0,
                small: 6.0,
                large: 8.0,
              ),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media
            if (post.mediaUrls.isNotEmpty)
              PostMediaWidget(
                mediaUrls: post.mediaUrls,
                aspectRatio: 16 / 9,
              ),
            
            // Content
            Padding(
              padding: context.responsivePadding(
                all: context.responsive(
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 16.0,
                              small: 17.0,
                              large: 18.0,
                            ),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: context.responsiveSpacing(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                      PostStatusChip(status: post.status),
                    ],
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 8.0,
                      small: 10.0,
                      large: 12.0,
                    ),
                  ),
                  
                  // Description
                  Text(
                    post.description,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 13.0,
                        small: 14.0,
                        large: 15.0,
                      ),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  
                  // Footer
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: context.responsiveIconSize(
                          verySmall: 14.0,
                          small: 15.0,
                          large: 16.0,
                        ),
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(
                        width: context.responsiveSpacing(
                          verySmall: 4.0,
                          small: 6.0,
                          large: 8.0,
                        ),
                      ),
                      Text(
                        _formatDate(post.postedAt),
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 12.0,
                            small: 13.0,
                            large: 14.0,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (post.mediaUrls.length > 1)
                        Row(
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: context.responsiveIconSize(
                                verySmall: 14.0,
                                small: 15.0,
                                large: 16.0,
                              ),
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(
                              width: context.responsiveSpacing(
                                verySmall: 4.0,
                                small: 6.0,
                                large: 8.0,
                              ),
                            ),
                            Text(
                              '${post.mediaUrls.length} ảnh',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 12.0,
                                  small: 13.0,
                                  large: 14.0,
                                ),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
