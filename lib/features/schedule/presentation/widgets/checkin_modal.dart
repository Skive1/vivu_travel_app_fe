import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../data/models/checkin_request.dart';
import '../../data/models/checkout_request.dart';

class CheckInModal extends StatefulWidget {
  final int activityId;
  final bool isCheckIn; // true for check-in, false for check-out
  final String attendanceStatus; // Current attendance status
  final VoidCallback? onSuccess;

  const CheckInModal({
    Key? key,
    required this.activityId,
    required this.isCheckIn,
    required this.attendanceStatus,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<CheckInModal> createState() => _CheckInModalState();
}

class _CheckInModalState extends State<CheckInModal> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper methods for status display
  Color _getStatusColor() {
    if (widget.isCheckIn) {
      if (widget.attendanceStatus == 'CheckIn') {
        return AppColors.success; // Already checked in
      }
      return AppColors.success; // Can check in
    } else {
      if (widget.attendanceStatus == 'CheckOut') {
        return AppColors.primary; // Already checked out
      }
      return AppColors.primary; // Can check out
    }
  }

  IconData _getStatusIcon() {
    if (widget.isCheckIn) {
      if (widget.attendanceStatus == 'CheckIn') {
        return Icons.check_circle; // Already completed
      }
      return Icons.login; // Can check in
    } else {
      if (widget.attendanceStatus == 'CheckOut') {
        return Icons.check_circle; // Already completed
      }
      return Icons.logout; // Can check out
    }
  }

  String _getStatusTitle() {
    if (widget.isCheckIn) {
      if (widget.attendanceStatus == 'CheckIn') {
        return 'Đã Check-in';
      }
      return 'Check-in';
    } else {
      if (widget.attendanceStatus == 'CheckOut') {
        return 'Đã Check-out';
      }
      return 'Check-out';
    }
  }

  String _getStatusSubtitle() {
    if (widget.isCheckIn) {
      if (widget.attendanceStatus == 'CheckIn') {
        return 'Bạn đã tham gia hoạt động này';
      }
      return 'Xác nhận tham gia hoạt động';
    } else {
      if (widget.attendanceStatus == 'CheckOut') {
        return 'Bạn đã hoàn thành hoạt động này';
      }
      return 'Xác nhận hoàn thành hoạt động';
    }
  }

  bool _isAlreadyCompleted() {
    if (widget.isCheckIn && widget.attendanceStatus == 'CheckIn') {
      return true;
    }
    if (!widget.isCheckIn && widget.attendanceStatus == 'CheckOut') {
      return true;
    }
    return false;
  }

  bool _isFullyCompleted() {
    return widget.attendanceStatus == 'CheckOut';
  }

  Future<void> _showImageSourceDialog() async {
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
                'Chọn nguồn ảnh',
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

  void _submitCheckIn() {
    // Check if already completed
    if (widget.isCheckIn && widget.attendanceStatus == 'CheckIn') {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Đã Check-in',
        message: 'Bạn đã check-in vào hoạt động này rồi.\n\n💡 Mỗi hoạt động chỉ có thể check-in một lần.',
        buttonText: 'Đóng',
      );
      return;
    }
    
    if (!widget.isCheckIn && widget.attendanceStatus == 'CheckOut') {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Đã Check-out',
        message: 'Bạn đã check-out khỏi hoạt động này rồi.\n\n💡 Mỗi hoạt động chỉ có thể check-out một lần.',
        buttonText: 'Đóng',
      );
      return;
    }

    if (_selectedImage == null) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Thiếu ảnh',
        message: 'Vui lòng chụp ảnh hoặc chọn ảnh từ thư viện để check-in/check-out.',
        buttonText: 'Đóng',
      );
      return;
    }

    setState(() => _isLoading = true);

    if (widget.isCheckIn) {
      context.read<ScheduleBloc>().add(
        CheckInActivityEvent(
          request: CheckInRequest(
            activityId: widget.activityId,
            file: _selectedImage!.path,
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
          ),
        ),
      );
    } else {
      context.read<ScheduleBloc>().add(
        CheckOutActivityEvent(
          request: CheckOutRequest(
            activityId: widget.activityId,
            file: _selectedImage!.path,
            description: _descriptionController.text.trim().isEmpty 
                ? null 
                : _descriptionController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is CheckInActivitySuccess || state is CheckOutActivitySuccess) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          widget.onSuccess?.call();
          DialogUtils.showSuccessDialog(
            context: context,
            title: widget.isCheckIn ? 'Check-in thành công!' : 'Check-out thành công!',
            message: widget.isCheckIn 
                ? 'Bạn đã check-in thành công vào hoạt động này.'
                : 'Bạn đã check-out thành công khỏi hoạt động này.',
            buttonText: 'Đóng',
          );
         } else if (state is CheckInActivityError) {
           setState(() => _isLoading = false);
           DialogUtils.showServerErrorDialog(
             context: context,
             serverMessage: state.message,
             title: 'Không thể Check-in',
             buttonText: 'Đóng',
           );
         } else if (state is CheckOutActivityError) {
           setState(() => _isLoading = false);
           DialogUtils.showServerErrorDialog(
             context: context,
             serverMessage: state.message,
             title: 'Không thể Check-out',
             buttonText: 'Đóng',
           );
         }
      },
      child: Stack(
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 16, small: 18, large: 20)),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.responsiveIconSize(verySmall: 320, small: 360, large: 400),
                maxHeight: context.responsiveHeightPercentage(verySmall: 0.85, small: 0.9, large: 0.95),
              ),
              padding: context.responsivePadding(all: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 16, small: 18, large: 20)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                    children: [
                      Container(
                        padding: context.responsivePadding(all: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: context.responsiveIconSize(verySmall: 20, small: 22, large: 24),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(),
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(verySmall: 18, small: 19, large: 20),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
                            Text(
                              _getStatusSubtitle(),
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: context.responsiveIconSize(verySmall: 20, small: 22, large: 24),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),

                  // Show completion status or form
                  if (_isAlreadyCompleted()) ...[
                    // Already completed status
                    Container(
                      width: double.infinity,
                      padding: context.responsivePadding(all: 20),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                        border: Border.all(
                          color: _getStatusColor().withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: context.responsiveIconSize(verySmall: 40, small: 44, large: 48),
                            color: _getStatusColor(),
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                          Text(
                            _getStatusTitle(),
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(),
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                          Text(
                            _getStatusSubtitle(),
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
                  ] else if (_isFullyCompleted()) ...[
                    // Fully completed - both CheckIn and CheckOut
                    Container(
                      width: double.infinity,
                      padding: context.responsivePadding(all: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: context.responsiveIconSize(verySmall: 32, small: 36, large: 40),
                                color: AppColors.success,
                              ),
                              SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                              Icon(
                                Icons.check_circle,
                                size: context.responsiveIconSize(verySmall: 32, small: 36, large: 40),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                          Text(
                            'Hoàn thành hoạt động',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                          Text(
                            'Bạn đã tham gia và hoàn thành hoạt động này',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: context.responsivePadding(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                ),
                                child: Text(
                                  'Đã Check-in',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                              Container(
                                padding: context.responsivePadding(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                ),
                                child: Text(
                                  'Đã Check-out',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
                  ] else ...[
                    // Image picker
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: context.responsiveIconSize(verySmall: 160, small: 180, large: 200),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                          border: Border.all(
                            color: _selectedImage != null 
                                ? AppColors.primary 
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _showImageSourceDialog,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: context.responsiveIconSize(verySmall: 40, small: 44, large: 48),
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                                  Text(
                                    'Chạm để chọn ảnh',
                                    style: TextStyle(
                                      fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
                                  Text(
                                    'Chụp ảnh hoặc chọn từ thư viện',
                                    style: TextStyle(
                                      fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 16, small: 18, large: 20)),

                    // Description field
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả (tùy chọn)',
                        hintText: widget.isCheckIn 
                            ? 'Chia sẻ cảm xúc của bạn...'
                            : 'Cảm nhận về hoạt động...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
                  ],

                  // Action buttons
                  if (_isAlreadyCompleted() || _isFullyCompleted()) ...[
                    // Only close button when already completed
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFullyCompleted() ? AppColors.primary : _getStatusColor(),
                          padding: context.responsivePadding(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isFullyCompleted() ? 'Hoàn thành' : 'Đóng',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Normal action buttons
                    ResponsiveUtils.isVerySmallPhone(context) 
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: context.responsivePadding(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
                                  ),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 12, large: 12)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _selectedImage != null ? _submitCheckIn : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isCheckIn 
                                      ? AppColors.success 
                                      : AppColors.primary,
                                  padding: context.responsivePadding(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  widget.isCheckIn ? 'Check-in' : 'Check-out',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: context.responsivePadding(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
                                  ),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _selectedImage != null ? _submitCheckIn : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isCheckIn 
                                      ? AppColors.success 
                                      : AppColors.primary,
                                  padding: context.responsivePadding(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  widget.isCheckIn ? 'Check-in' : 'Check-out',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                  ],
                ),
              ),
            ),
          ),
          LoadingOverlay(isLoading: _isLoading),
        ],
      ),
    );
  }
}
