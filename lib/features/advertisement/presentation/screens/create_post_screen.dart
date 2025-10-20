import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';
import '../widgets/image_picker_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File> _selectedImages = [];
  final List<int> _mediaTypes = []; // 0 for image, 1 for video
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Tạo bài đăng',
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
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: Text(
              'Đăng',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AdvertisementBloc, AdvertisementState>(
        listener: (context, state) {
          if (state is PostCreated) {
            DialogUtils.showSuccessDialog(
              context: context,
              title: 'Thành công!',
              message: 'Bài đăng đã được tạo thành công và đang chờ duyệt.',
              buttonText: 'Đóng',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to explore screen
              },
            );
          } else if (state is AdvertisementError) {
            DialogUtils.showErrorDialog(
              context: context,
              message: state.message,
            );
          }
          setState(() {
            _isLoading = state is AdvertisementLoading;
          });
        },
        builder: (context, state) {
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.title_outlined,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tiêu đề',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 16.0,
                                small: 18.0,
                                large: 20.0,
                              ),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tiêu đề bài đăng...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: context.responsiveFontSize(
                              verySmall: 15.0,
                              small: 16.0,
                              large: 17.0,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFF6366F1), width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
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
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          if (value.trim().length < 5) {
                            return 'Tiêu đề phải có ít nhất 5 ký tự';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 20.0,
                          small: 24.0,
                          large: 28.0,
                        ),
                      ),
                      // Description field
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: Color(0xFF8B5CF6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Nội dung',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 16.0,
                                small: 18.0,
                                large: 20.0,
                              ),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Nhập nội dung bài đăng...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: context.responsiveFontSize(
                              verySmall: 15.0,
                              small: 16.0,
                              large: 17.0,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: const Color(0xFF8B5CF6), width: 2.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
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
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          if (value.trim().length < 20) {
                            return 'Nội dung phải có ít nhất 20 ký tự';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 20.0,
                          small: 24.0,
                          large: 28.0,
                        ),
                      ),
                      // Media picker
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Hình ảnh/Video',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 16.0,
                                small: 18.0,
                                large: 20.0,
                              ),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                      ImagePickerWidget(
                        selectedImages: _selectedImages,
                        mediaTypes: _mediaTypes,
                        onImagesChanged: (images, types) {
                          setState(() {
                            _selectedImages.clear();
                            _mediaTypes.clear();
                            _selectedImages.addAll(images);
                            _mediaTypes.addAll(types);
                          });
                        },
                      ),
                      SizedBox(
                        height: context.responsive(
                          verySmall: 20.0,
                          small: 24.0,
                          large: 28.0,
                        ),
                      ),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsive(
                                verySmall: 18.0,
                                small: 20.0,
                                large: 22.0,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 0,
                            shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: context.responsive(
                                    verySmall: 16.0,
                                    small: 18.0,
                                    large: 20.0,
                                  ),
                                  width: context.responsive(
                                    verySmall: 16.0,
                                    small: 18.0,
                                    large: 20.0,
                                  ),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  'Tạo bài đăng',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(
                                      verySmall: 16.0,
                                      small: 17.0,
                                      large: 18.0,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
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
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitPost() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      DialogUtils.showErrorDialog(
        context: context,
        message: 'Vui lòng chọn ít nhất một hình ảnh hoặc video',
      );
      return;
    }

    // TODO: Get packagePurchaseId from user's purchased packages
    // For now, using a placeholder - in real app, this should come from user's purchased packages
    const packagePurchaseId = 'placeholder-package-id';

    final mediaFiles = _selectedImages.map((file) => file.path).toList();

    context.read<AdvertisementBloc>().add(
          CreatePost(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            packagePurchaseId: packagePurchaseId,
            mediaFiles: mediaFiles,
            mediaTypes: _mediaTypes,
          ),
        );
  }
}
