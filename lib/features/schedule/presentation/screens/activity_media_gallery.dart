import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/media_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import 'image_viewer_screen.dart';

class ActivityMediaGallery extends StatefulWidget {
  final int activityId;
  final String activityTitle;

  const ActivityMediaGallery({
    Key? key,
    required this.activityId,
    required this.activityTitle,
  }) : super(key: key);

  @override
  State<ActivityMediaGallery> createState() => _ActivityMediaGalleryState();
}

class _ActivityMediaGalleryState extends State<ActivityMediaGallery> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(
      GetMediaByActivityEvent(activityId: widget.activityId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: context.responsiveIconSize(
              verySmall: 18,
              small: 20,
              large: 24,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          padding: context.responsivePadding(
            all: context.responsive(
              verySmall: 6,
              small: 8,
              large: 12,
            ),
          ),
          constraints: context.responsive(
            verySmall: BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            small: BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            large: BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
        title: Text(
          'Ảnh hoạt động',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.responsiveFontSize(
              verySmall: 14,
              small: 16,
              large: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is GetMediaByActivityLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is GetMediaByActivityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải ảnh',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScheduleBloc>().add(
                        GetMediaByActivityEvent(activityId: widget.activityId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is GetMediaByActivitySuccess) {
            if (state.mediaList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có ảnh nào',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy check-in/check-out để thêm ảnh',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header info
                Container(
                  width: double.infinity,
                  padding: context.responsivePadding(
                    all: context.responsive(
                      verySmall: 10,
                      small: 12,
                      large: 16,
                    ),
                  ),
                  margin: context.responsiveMargin(
                    all: context.responsive(
                      verySmall: 10,
                      small: 12,
                      large: 16,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                      verySmall: 6,
                      small: 8,
                      large: 12,
                    )),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: context.responsive(
                          verySmall: 4,
                          small: 6,
                          large: 8,
                        ),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activityTitle,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 12,
                            small: 14,
                            large: 16,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 4,
                        small: 6,
                        large: 8,
                      )),
                      Text(
                        '${state.mediaList.length} ảnh',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 10,
                            small: 12,
                            large: 14,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Media grid
                Expanded(
                  child: GridView.builder(
                    padding: context.responsivePadding(
                      horizontal: context.responsive(
                        verySmall: 10,
                        small: 12,
                        large: 16,
                      ),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: context.responsive(
                        verySmall: 6,
                        small: 8,
                        large: 12,
                      ),
                      mainAxisSpacing: context.responsive(
                        verySmall: 6,
                        small: 8,
                        large: 12,
                      ),
                      childAspectRatio: 1,
                    ),
                    itemCount: state.mediaList.length,
                    itemBuilder: (context, index) {
                      final media = state.mediaList[index];
                      return _buildMediaCard(media);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMediaCard(MediaEntity media) {
    return GestureDetector(
      onTap: () => _showMediaDetail(media),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
            verySmall: 6,
            small: 8,
            large: 12,
          )),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: context.responsive(
                verySmall: 4,
                small: 6,
                large: 8,
              ),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
            verySmall: 6,
            small: 8,
            large: 12,
          )),
          child: Stack(
            children: [
              // Image
              Image.network(
                media.url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // Overlay with type indicator
              Positioned(
                top: context.responsive(
                  verySmall: 4,
                  small: 6,
                  large: 8,
                ),
                right: context.responsive(
                  verySmall: 4,
                  small: 6,
                  large: 8,
                ),
                child: Container(
                  padding: context.responsivePadding(
                    horizontal: context.responsive(
                      verySmall: 4,
                      small: 6,
                      large: 8,
                    ),
                    vertical: context.responsive(
                      verySmall: 2,
                      small: 3,
                      large: 4,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(media.uploadMethod).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                      verySmall: 6,
                      small: 8,
                      large: 12,
                    )),
                  ),
                  child: Text(
                    media.uploadMethodText,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 8,
                        small: 9,
                        large: 10,
                      ),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Description overlay
              if (media.description != null && media.description!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: context.responsivePadding(
                      all: context.responsive(
                        verySmall: 4,
                        small: 6,
                        large: 8,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      media.description!,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 8,
                          small: 10,
                          large: 12,
                        ),
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(int uploadMethod) {
    switch (uploadMethod) {
      case 0: // Check-in
        return AppColors.success;
      case 1: // Check-out
        return AppColors.primary;
      case 2: // Normal
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showMediaDetail(MediaEntity media) {
    final mediaList = context.read<ScheduleBloc>().state is GetMediaByActivitySuccess
        ? (context.read<ScheduleBloc>().state as GetMediaByActivitySuccess).mediaList
        : <MediaEntity>[];
    
    final initialIndex = mediaList.indexWhere((m) => m.id == media.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          mediaList: mediaList,
          initialIndex: initialIndex >= 0 ? initialIndex : 0,
        ),
      ),
    );
  }
}
