import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/post_entity.dart';
import 'post_card_widget.dart';
import 'empty_state_widget.dart';
import '../screens/post_detail_screen.dart';
import '../bloc/advertisement_bloc.dart';

class PostListWidget extends StatelessWidget {
  final List<PostEntity> posts;
  final bool isLoading;

  const PostListWidget({
    super.key,
    required this.posts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (posts.isEmpty) {
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
    );
  }
}
