import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import 'image_picker_widget.dart';

class RichTextEditor extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onTextChanged;
  final List<File> selectedImages;
  final ValueChanged<List<File>> onImagesChanged;
  final List<int> mediaTypes;
  final ValueChanged<List<int>> onMediaTypesChanged;

  const RichTextEditor({
    super.key,
    this.initialText = '',
    required this.onTextChanged,
    required this.selectedImages,
    required this.onImagesChanged,
    required this.mediaTypes,
    required this.onMediaTypesChanged,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isBulletList = false;
  bool _isNumberedList = false;
  int _currentIndent = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() {
      widget.onTextChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Editor
          Expanded(
            child: _buildEditor(),
          ),
          // Image gallery
          if (widget.selectedImages.isNotEmpty) _buildImageGallery(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(verySmall: 12.0, small: 16.0, large: 20.0),
        vertical: context.responsive(verySmall: 8.0, small: 10.0, large: 12.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Bold
            _buildToolbarButton(
              icon: Icons.format_bold,
              isActive: _isBold,
              onTap: _toggleBold,
            ),
            const SizedBox(width: 8),
            // Italic
            _buildToolbarButton(
              icon: Icons.format_italic,
              isActive: _isItalic,
              onTap: _toggleItalic,
            ),
            const SizedBox(width: 8),
            // Underline
            _buildToolbarButton(
              icon: Icons.format_underlined,
              isActive: _isUnderline,
              onTap: _toggleUnderline,
            ),
            const SizedBox(width: 16),
            // Bullet list
            _buildToolbarButton(
              icon: Icons.format_list_bulleted,
              isActive: _isBulletList,
              onTap: _toggleBulletList,
            ),
            const SizedBox(width: 8),
            // Numbered list
            _buildToolbarButton(
              icon: Icons.format_list_numbered,
              isActive: _isNumberedList,
              onTap: _toggleNumberedList,
            ),
            const SizedBox(width: 16),
            // Indent left
            _buildToolbarButton(
              icon: Icons.format_indent_decrease,
              onTap: _decreaseIndent,
            ),
            const SizedBox(width: 8),
            // Indent right
            _buildToolbarButton(
              icon: Icons.format_indent_increase,
              onTap: _increaseIndent,
            ),
            const SizedBox(width: 16),
            // Add image
            _buildToolbarButton(
              icon: Icons.image_outlined,
              onTap: _addImage,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              iconColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? AppColors.primary : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: AppColors.primary) : null,
        ),
        child: Icon(
          icon,
          size: context.responsiveIconSize(verySmall: 16.0, small: 18.0, large: 20.0),
          color: iconColor ?? (isActive ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: EdgeInsets.all(context.responsive(verySmall: 16.0, small: 20.0, large: 24.0)),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: context.responsiveFontSize(verySmall: 15.0, small: 16.0, large: 17.0),
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
          height: 1.6,
        ),
        decoration: const InputDecoration(
          hintText: 'Viết nội dung bài đăng của bạn...\n\nBạn có thể sử dụng các công cụ định dạng ở trên để tạo bài viết chuyên nghiệp.',
          hintStyle: TextStyle(
            color: Color(0xFF94A3B8),
            height: 1.6,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.selectedImages.length) {
            return _buildAddImageButton();
          }
          return _buildImageItem(index);
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _addImage,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: context.responsiveIconSize(verySmall: 20.0, small: 24.0, large: 28.0),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm',
              style: TextStyle(
                fontSize: context.responsiveFontSize(verySmall: 10.0, small: 11.0, large: 12.0),
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final file = widget.selectedImages[index];
    final isVideo = widget.mediaTypes[index] == 1;
    
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          if (isVideo)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
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
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  void _toggleUnderline() {
    setState(() {
      _isUnderline = !_isUnderline;
    });
  }

  void _toggleBulletList() {
    setState(() {
      _isBulletList = !_isBulletList;
      if (_isBulletList) {
        _isNumberedList = false;
      }
    });
  }

  void _toggleNumberedList() {
    setState(() {
      _isNumberedList = !_isNumberedList;
      if (_isNumberedList) {
        _isBulletList = false;
      }
    });
  }

  void _decreaseIndent() {
    setState(() {
      if (_currentIndent > 0) {
        _currentIndent--;
      }
    });
  }

  void _increaseIndent() {
    setState(() {
      _currentIndent++;
    });
  }

  void _addImage() {
    // Show image picker widget in a modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Thêm hình ảnh',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(verySmall: 18.0, small: 20.0, large: 22.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Image picker widget
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ImagePickerWidget(
                  selectedImages: widget.selectedImages,
                  mediaTypes: widget.mediaTypes,
                  onImagesChanged: (images, types) {
                    _insertImageAtCursor(images, types);
                  },
                  maxImages: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertImageAtCursor(List<File> updatedImages, List<int> updatedTypes) {
    setState(() {
      // Determine how many images are newly added compared to current state
      final currentCount = widget.selectedImages.length;
      final totalCount = updatedImages.length;
      final newlyAddedCount = totalCount - currentCount;

      if (newlyAddedCount <= 0) {
        // Nothing new to insert; just close picker and return
        Navigator.of(context).maybePop();
        return;
      }

      // Get safe cursor position; if -1 or out of bounds, append at end
      int cursorPosition = _controller.selection.baseOffset;
      final text = _controller.text;
      if (cursorPosition < 0 || cursorPosition > text.length) {
        cursorPosition = text.length;
      }

      // Build placeholders for newly added images
      final StringBuffer placeholderBuffer = StringBuffer();
      for (int i = currentCount; i < totalCount; i++) {
        if (placeholderBuffer.isNotEmpty) placeholderBuffer.write(' ');
        placeholderBuffer.write('[IMAGE:$i]');
      }

      // Insert placeholders at cursor
      final String newText = text.substring(0, cursorPosition) +
          placeholderBuffer.toString() +
          text.substring(cursorPosition);

      // Update controller text and move cursor after inserted placeholders
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset: cursorPosition + placeholderBuffer.length,
      );

      // Notify parent with the full updated lists from picker
      widget.onImagesChanged(updatedImages);
      widget.onMediaTypesChanged(updatedTypes);

      // Close the bottom sheet if open
      Navigator.of(context).maybePop();
    });
  }

  void _removeImage(int index) {
    setState(() {
      // Remove image placeholder from text
      final imagePlaceholder = '[IMAGE:$index]';
      final text = _controller.text;
      final newText = text.replaceFirst(imagePlaceholder, '');
      
      // Update text controller
      _controller.text = newText;
      
      // Remove image from lists
      widget.selectedImages.removeAt(index);
      widget.mediaTypes.removeAt(index);
      
      // Notify parent
      widget.onImagesChanged(widget.selectedImages);
      widget.onMediaTypesChanged(widget.mediaTypes);
    });
  }
}
