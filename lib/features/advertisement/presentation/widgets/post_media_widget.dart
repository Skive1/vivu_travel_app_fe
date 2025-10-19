import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class PostMediaWidget extends StatelessWidget {
  final List<String> mediaUrls;
  final double aspectRatio;
  final Function(int)? onImageTap;

  const PostMediaWidget({
    super.key,
    required this.mediaUrls,
    this.aspectRatio = 16 / 9,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    if (mediaUrls.length == 1) {
      return _buildSingleMedia(context, mediaUrls.first);
    } else {
      return _buildMultipleMedia(context);
    }
  }

  Widget _buildSingleMedia(BuildContext context, String url) {
    return GestureDetector(
      onTap: onImageTap != null ? () => onImageTap!(0) : null,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              context.responsiveBorderRadius(
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
            ),
          ),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleMedia(BuildContext context) {
    return GestureDetector(
      onTap: onImageTap != null ? () => onImageTap!(0) : null,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            context.responsiveBorderRadius(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
        ),
        child: Stack(
          children: [
            // First image
            Image.network(
              mediaUrls.first,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
            
            // Overlay for multiple images
            if (mediaUrls.length > 1)
              Positioned(
                top: context.responsive(
                  verySmall: 8.0,
                  small: 10.0,
                  large: 12.0,
                ),
                right: context.responsive(
                  verySmall: 8.0,
                  small: 10.0,
                  large: 12.0,
                ),
                child: Container(
                  padding: context.responsivePadding(
                    horizontal: context.responsive(
                      verySmall: 6.0,
                      small: 8.0,
                      large: 10.0,
                    ),
                    vertical: context.responsive(
                      verySmall: 3.0,
                      small: 4.0,
                      large: 5.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(
                      context.responsiveBorderRadius(
                        verySmall: 8.0,
                        small: 10.0,
                        large: 12.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: context.responsiveIconSize(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: context.responsiveSpacing(
                          verySmall: 2.0,
                          small: 4.0,
                          large: 6.0,
                        ),
                      ),
                      Text(
                        '${mediaUrls.length}',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 11.0,
                            small: 12.0,
                            large: 13.0,
                          ),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
