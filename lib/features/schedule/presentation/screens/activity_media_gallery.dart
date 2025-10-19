import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../domain/entities/media_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../data/models/upload_media_request.dart';
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
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(
      GetMediaByActivityEvent(activityId: widget.activityId),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is UploadMediaSuccess) {
          setState(() => _isUploading = false);
          Navigator.pop(context); // Close upload dialog
          setState(() {
            _selectedImage = null;
            _descriptionController.clear();
          });
          // Refresh media list
          context.read<ScheduleBloc>().add(
            GetMediaByActivityEvent(activityId: widget.activityId),
          );
          DialogUtils.showSuccessDialog(
            context: context,
            title: 'Đăng ảnh thành công!',
            message: 'Ảnh đã được thêm vào hoạt động.',
            buttonText: 'Đóng',
          );
        } else if (state is UploadMediaError) {
          setState(() => _isUploading = false);
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Lỗi đăng ảnh',
            message: state.message,
            buttonText: 'Đóng',
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
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
        actions: [
          IconButton(
            onPressed: _showUploadModal,
            icon: Icon(
              Icons.add_a_photo,
              color: AppColors.primary,
              size: context.responsiveIconSize(
                verySmall: 18,
                small: 20,
                large: 24,
              ),
            ),
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
        ],
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
          ),
          LoadingOverlay(isLoading: _isUploading),
        ],
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

              // Participant info overlay
              if (media.participantName != null && media.participantName!.isNotEmpty)
                Positioned(
                  top: context.responsive(
                    verySmall: 4,
                    small: 6,
                    large: 8,
                  ),
                  left: context.responsive(
                    verySmall: 4,
                    small: 6,
                    large: 8,
                  ),
                  child: Container(
                    padding: context.responsivePadding(
                      horizontal: context.responsive(
                        verySmall: 6,
                        small: 8,
                        large: 10,
                      ),
                      vertical: context.responsive(
                        verySmall: 3,
                        small: 4,
                        large: 5,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                        verySmall: 8,
                        small: 10,
                        large: 12,
                      )),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        if (media.participantAvatar != null && media.participantAvatar!.isNotEmpty)
                          Container(
                            width: context.responsive(
                              verySmall: 16,
                              small: 18,
                              large: 20,
                            ),
                            height: context.responsive(
                              verySmall: 16,
                              small: 18,
                              large: 20,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                media.participantAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.background,
                                  child: Icon(
                                    Icons.person,
                                    size: context.responsive(
                                      verySmall: 8,
                                      small: 10,
                                      large: 12,
                                    ),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (media.participantAvatar != null && media.participantAvatar!.isNotEmpty)
                          SizedBox(width: context.responsive(
                            verySmall: 4,
                            small: 5,
                            large: 6,
                          )),
                        // Name
                        Flexible(
                          child: Text(
                            media.participantName!,
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 8,
                                small: 9,
                                large: 10,
                              ),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  void _showUploadModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Thêm ảnh vào hoạt động',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Chụp ảnh',
                    subtitle: 'Sử dụng camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library,
                    title: 'Thư viện',
                    subtitle: 'Chọn từ thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showUploadDialog();
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorDialog(
          context: context,
          title: 'Lỗi chọn ảnh',
          message: 'Không thể chọn ảnh. Vui lòng thử lại.\n\nChi tiết: $e',
          buttonText: 'Đóng',
        );
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chia sẻ ảnh về hoạt động',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Image preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  hintText: 'Chia sẻ cảm xúc về hoạt động...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _uploadMedia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đăng ảnh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadMedia() {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    context.read<ScheduleBloc>().add(
      UploadMediaEvent(
        request: UploadMediaRequest(
          file: _selectedImage!.path,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          uploadMethod: 2, // Normal upload
          activityId: widget.activityId,
        ),
      ),
    );
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
