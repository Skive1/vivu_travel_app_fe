import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../data/models/add_participant_by_email_request.dart';

class InviteParticipantModal extends StatefulWidget {
  final String scheduleId;

  const InviteParticipantModal({
    Key? key,
    required this.scheduleId,
  }) : super(key: key);

  @override
  State<InviteParticipantModal> createState() => _InviteParticipantModalState();
}

class _InviteParticipantModalState extends State<InviteParticipantModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _inviteParticipant() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final request = AddParticipantByEmailRequest(
        email: _emailController.text.trim(),
      );

      context.read<ScheduleBloc>().add(
        AddParticipantByEmailEvent(
          scheduleId: widget.scheduleId,
          request: request,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is AddParticipantByEmailLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AddParticipantByEmailSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
          DialogUtils.showSuccessDialog(
            context: context,
            title: 'Thành công',
            message: state.message,
            buttonText: 'Đóng',
          );
        } else if (state is AddParticipantByEmailError) {
          setState(() {
            _isLoading = false;
          });
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Lỗi',
            message: state.message,
            buttonText: 'Đóng',
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mời người tham gia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Nhập email của người bạn muốn mời tham gia lịch trình này.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email người dùng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Nhập email người dùng',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.inputFocused, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: AppColors.surface,
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _inviteParticipant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Gửi lời mời',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
