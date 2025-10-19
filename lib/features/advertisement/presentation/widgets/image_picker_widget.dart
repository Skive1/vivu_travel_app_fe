import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<File> selectedImages;
  final List<int> mediaTypes; // 0 for image, 1 for video
  final Function(List<File>, List<int>) onImagesChanged;
  final int maxImages;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.mediaTypes,
    required this.onImagesChanged,
    this.maxImages = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(
              context.responsive(
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: context.responsiveIconSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                ),
                SizedBox(
                  width: context.responsive(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                ),
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
                const Spacer(),
                Text(
                  '${selectedImages.length}/$maxImages',
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
          ),
          // Images grid
          if (selectedImages.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: context.responsive(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                  mainAxisSpacing: context.responsive(
                    verySmall: 8.0,
                    small: 10.0,
                    large: 12.0,
                  ),
                  childAspectRatio: 1.0,
                ),
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(context, index);
                },
              ),
            ),
          // Add button
          if (selectedImages.length < maxImages)
            Padding(
              padding: EdgeInsets.all(
                context.responsive(
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
              ),
              child: _buildAddButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, int index) {
    final file = selectedImages[index];
    final isVideo = mediaTypes[index] == 1;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: isVideo
                ? Stack(
                    children: [
                      Image.file(
                        file,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: context.responsiveIconSize(
                              verySmall: 24.0,
                              small: 28.0,
                              large: 32.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    file,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: context.responsiveIconSize(
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
              ),
            ),
          ),
        ),
        // Media type indicator
        if (isVideo)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.responsiveFontSize(
                    verySmall: 8.0,
                    small: 9.0,
                    large: 10.0,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        width: double.infinity,
        height: context.responsive(
          verySmall: 80.0,
          small: 90.0,
          large: 100.0,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: AppColors.primary,
              size: context.responsiveIconSize(
                verySmall: 24.0,
                small: 28.0,
                large: 32.0,
              ),
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 4.0,
                small: 6.0,
                large: 8.0,
              ),
            ),
            Text(
              'Thêm ảnh/video',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 12.0,
                  small: 13.0,
                  large: 14.0,
                ),
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(
          context.responsive(
            verySmall: 20.0,
            small: 24.0,
            large: 28.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 20.0,
                small: 24.0,
                large: 28.0,
              ),
            ),
            Text(
              'Chọn nguồn',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 16.0,
                  small: 18.0,
                  large: 20.0,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(
              height: context.responsive(
                verySmall: 20.0,
                small: 24.0,
                large: 28.0,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    context,
                    icon: Icons.photo_camera,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(
                  width: context.responsive(
                    verySmall: 16.0,
                    small: 20.0,
                    large: 24.0,
                  ),
                ),
                Expanded(
                  child: _buildSourceOption(
                    context,
                    icon: Icons.photo_library,
                    title: 'Thư viện',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
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
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          context.responsive(
            verySmall: 16.0,
            small: 20.0,
            large: 24.0,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: context.responsiveIconSize(
                verySmall: 32.0,
                small: 36.0,
                large: 40.0,
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
              title,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final newImages = List<File>.from(selectedImages)..add(file);
        final newTypes = List<int>.from(mediaTypes)..add(0); // 0 for image
        
        onImagesChanged(newImages, newTypes);
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(selectedImages)..removeAt(index);
    final newTypes = List<int>.from(mediaTypes)..removeAt(index);
    
    onImagesChanged(newImages, newTypes);
  }
}
