import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';
import '../widgets/post_media_widget.dart';
import '../widgets/post_status_chip.dart';
import 'image_viewer_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<AdvertisementBloc>().add(LoadPostById(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Chi tiết bài đăng',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 18.0,
              small: 20.0,
              large: 22.0,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: context.responsiveIconSize(
              verySmall: 18.0,
              small: 20.0,
              large: 22.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
            },
            icon: Icon(
              Icons.share,
              color: AppColors.textPrimary,
              size: context.responsiveIconSize(
                verySmall: 18.0,
                small: 20.0,
                large: 22.0,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AdvertisementBloc, AdvertisementState>(
        listener: (context, state) {
          setState(() {
            _isLoading = state is AdvertisementLoading;
          });
        },
        builder: (context, state) {
          if (state is PostDetailLoaded) {
            return _buildPostDetail(context, state.post);
          } else if (state is AdvertisementError) {
            return _buildErrorState(context, state.message);
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPostDetail(BuildContext context, PostEntity post) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(
            context.responsive(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  context.responsive(
                    verySmall: 16.0,
                    small: 20.0,
                    large: 24.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 18.0,
                          small: 20.0,
                          large: 22.0,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: context.responsive(
                        verySmall: 8.0,
                        small: 10.0,
                        large: 12.0,
                      ),
                    ),
                    // Status
                    Row(
                      children: [
                        PostStatusChip(status: post.status),
                        const Spacer(),
                        Text(
                          _formatDate(post.postedAt),
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 12.0,
                              small: 13.0,
                              large: 14.0,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: context.responsive(
                  verySmall: 16.0,
                  small: 20.0,
                  large: 24.0,
                ),
              ),
              // Description
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  context.responsive(
                    verySmall: 16.0,
                    small: 20.0,
                    large: 24.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nội dung',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 14.0,
                          small: 15.0,
                          large: 16.0,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: context.responsive(
                        verySmall: 8.0,
                        small: 10.0,
                        large: 12.0,
                      ),
                    ),
                    Text(
                      post.description,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 14.0,
                          small: 15.0,
                          large: 16.0,
                        ),
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: context.responsive(
                  verySmall: 16.0,
                  small: 20.0,
                  large: 24.0,
                ),
              ),
              // Media
              if (post.mediaUrls.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    context.responsive(
                      verySmall: 16.0,
                      small: 20.0,
                      large: 24.0,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hình ảnh/Video',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 14.0,
                            small: 15.0,
                            large: 16.0,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        ),
                      ),
                      PostMediaWidget(
                        mediaUrls: post.mediaUrls,
                        onImageTap: (index) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImageViewerScreen(
                                images: post.mediaUrls,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: context.responsive(
                  verySmall: 16.0,
                  small: 20.0,
                  large: 24.0,
                ),
              ),
              // Post info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  context.responsive(
                    verySmall: 16.0,
                    small: 20.0,
                    large: 24.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin bài đăng',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 14.0,
                          small: 15.0,
                          large: 16.0,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(
                      height: context.responsive(
                        verySmall: 12.0,
                        small: 14.0,
                        large: 16.0,
                      ),
                    ),
                    _buildInfoRow(
                      context,
                      'ID bài đăng',
                      post.id,
                    ),
                    _buildInfoRow(
                      context,
                      'Ngày tạo',
                      _formatDate(post.createdAt),
                    ),
                    if (post.approvedBy != null)
                      _buildInfoRow(
                        context,
                        'Được duyệt bởi',
                        post.approvedBy!,
                      ),
                    if (post.approvedAt != null)
                      _buildInfoRow(
                        context,
                        'Ngày duyệt',
                        _formatDate(post.approvedAt!),
                      ),
                    _buildInfoRow(
                      context,
                      'Số lượng media',
                      '${post.mediaUrls.length}',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 28.0,
                ),
              ),
            ],
          ),
        ),
        LoadingOverlay(isLoading: _isLoading),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsive(
          verySmall: 8.0,
          small: 10.0,
          large: 12.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.responsive(
              verySmall: 100.0,
              small: 120.0,
              large: 140.0,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 13.0,
                  small: 14.0,
                  large: 15.0,
                ),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 13.0,
                  small: 14.0,
                  large: 15.0,
                ),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive(
            verySmall: 20.0,
            small: 24.0,
            large: 28.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.responsiveIconSize(
                verySmall: 48.0,
                small: 56.0,
                large: 64.0,
              ),
              color: Colors.grey[400],
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 16.0,
                small: 20.0,
                large: 24.0,
              ),
            ),
            Text(
              'Không thể tải bài đăng',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 16.0,
                  small: 18.0,
                  large: 20.0,
                ),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              ),
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 20.0,
                small: 24.0,
                large: 28.0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AdvertisementBloc>().add(LoadPostById(widget.postId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    verySmall: 24.0,
                    small: 28.0,
                    large: 32.0,
                  ),
                  vertical: context.responsive(
                    verySmall: 12.0,
                    small: 14.0,
                    large: 16.0,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 14.0,
                    small: 15.0,
                    large: 16.0,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
