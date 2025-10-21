import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
// AppColors no longer needed here after skeleton loading, remove import
import '../../domain/entities/post_entity.dart';
import 'post_card_widget.dart';
import 'empty_state_widget.dart';
import '../screens/post_detail_screen.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';

class PostListWidget extends StatelessWidget {
  final List<PostEntity> posts;
  final bool isLoading;
  final bool hasLoaded;

  const PostListWidget({
    super.key,
    required this.posts,
    this.isLoading = false,
    this.hasLoaded = false,
  });

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading when loading and no data yet
    if (isLoading && !hasLoaded && posts.isEmpty) {
      return _buildSkeletonList(context);
    }

    // Show empty state only when data has been loaded and is actually empty
    if (hasLoaded && posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'Chưa có bài đăng nào',
        subtitle: 'Các đối tác sẽ đăng bài quảng cáo tại đây',
        actionText: 'Làm mới',
        onAction: () {
          // Refresh will be handled by parent
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        right: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        top: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        bottom: context.responsive(
          verySmall: 80.0,
          small: 90.0,
          large: 100.0,
        ),
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: context.responsiveSpacing(
              verySmall: 12.0,
              small: 16.0,
              large: 20.0,
            ),
          ),
          child: PostCardWidget(
            post: post,
            onTap: () => _navigateToPostDetail(context, post),
          ),
        );
      },
    );
  }

  void _navigateToPostDetail(BuildContext context, PostEntity post) {
    // Get the current bloc instance from the widget tree
    final bloc = context.read<AdvertisementBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: PostDetailScreen(postId: post.id),
        ),
      ),
    ).then((_) {
      // Refresh posts when returning from detail to reflect any changes
      context.read<AdvertisementBloc>().add(const RefreshPosts());
    });
  }

  Widget _buildSkeletonList(BuildContext context) {
    // Simple non-shimmer skeleton placeholders
    return ListView.builder(
      padding: EdgeInsets.only(
        left: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        right: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        top: context.responsive(
          verySmall: 8.0,
          small: 12.0,
          large: 16.0,
        ),
        bottom: context.responsive(
          verySmall: 80.0,
          small: 90.0,
          large: 100.0,
        ),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: context.responsiveSpacing(
              verySmall: 12.0,
              small: 16.0,
              large: 20.0,
            ),
          ),
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
                // Media placeholder
                AspectRatio(
                  aspectRatio: 16 / 9,
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
                    child: Container(color: Colors.grey[200]),
                  ),
                ),

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
                      // Title line
                      Container(
                        height: context.responsive(
                          verySmall: 14.0,
                          small: 16.0,
                          large: 18.0,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(
                        height: context.responsiveSpacing(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                      // Second line
                      Container(
                        height: context.responsive(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        ),
                        width: context.responsive(
                          verySmall: 220.0,
                          small: 260.0,
                          large: 300.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      SizedBox(
                        height: context.responsiveSpacing(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        ),
                      ),
                      // Footer row
                      Row(
                        children: [
                          Container(
                            height: context.responsive(
                              verySmall: 10.0,
                              small: 12.0,
                              large: 14.0,
                            ),
                            width: context.responsive(
                              verySmall: 80.0,
                              small: 100.0,
                              large: 120.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: context.responsive(
                              verySmall: 10.0,
                              small: 12.0,
                              large: 14.0,
                            ),
                            width: context.responsive(
                              verySmall: 60.0,
                              small: 70.0,
                              large: 80.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
      },
    );
  }
}
