import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/update_activity_request.dart';
import '../../domain/entities/activity_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class EditActivitySheet extends StatefulWidget {
  final ActivityEntity activity;
  final BuildContext rootContext;

  const EditActivitySheet({super.key, required this.activity, required this.rootContext});

  @override
  State<EditActivitySheet> createState() => _EditActivitySheetState();
}

class _EditActivitySheetState extends State<EditActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placeCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _descCtrl;
  late TimeOfDay _checkIn;
  late TimeOfDay _checkOut;
  late int _orderIndex;

  @override
  void initState() {
    super.initState();
    _placeCtrl = TextEditingController(text: widget.activity.placeName);
    _locCtrl = TextEditingController(text: widget.activity.location);
    _descCtrl = TextEditingController(text: widget.activity.description);
    _orderIndex = widget.activity.orderIndex;
    _checkIn = TimeOfDay.fromDateTime(widget.activity.checkInTime);
    _checkOut = TimeOfDay.fromDateTime(widget.activity.checkOutTime);
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _locCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is UpdateActivitySuccess) {
          // Capture a stable overlay context from the current (still-mounted) context
          final stableOverlayCtx = Navigator.of(context, rootNavigator: true).overlay?.context;
          if (mounted) Navigator.of(context).pop();
          await DialogUtils.showSuccessDialog(
            context: stableOverlayCtx ?? widget.rootContext,
            title: 'Cập nhật thành công',
            message: 'Hoạt động đã được cập nhật.',
            useRootNavigator: true,
          );
        } else if (state is UpdateActivityError) {
          final stableOverlayCtx = Navigator.of(context, rootNavigator: true).overlay?.context;
          if (mounted) Navigator.of(context).pop();
          await DialogUtils.showErrorDialog(
            context: stableOverlayCtx ?? widget.rootContext,
            title: 'Cập nhật thất bại',
            message: state.message,
            useRootNavigator: true,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdateActivityLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chỉnh sửa hoạt động',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placeCtrl,
                    decoration: _inputDecoration('Tên địa điểm', Icons.place_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên địa điểm' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locCtrl,
                    decoration: _inputDecoration('Địa chỉ', Icons.location_on_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: _inputDecoration('Mô tả (tuỳ chọn)', Icons.notes_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Check-in ${_checkIn.format(context)}',
                          onPick: () async {
                            final t = await showTimePicker(context: context, initialTime: _checkIn);
                            if (t != null) setState(() => _checkIn = t);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Check-out ${_checkOut.format(context)}',
                          onPick: () async {
                            final t = await showTimePicker(context: context, initialTime: _checkOut);
                            if (t != null) setState(() => _checkOut = t);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOrderIndexPicker(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Huỷ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save),
                          label: const Text('Lưu thay đổi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      },
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildTimePicker({required String label, required VoidCallback onPick}) {
    return OutlinedButton(
      onPressed: onPick,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final inDt = DateTime(widget.activity.checkInTime.year, widget.activity.checkInTime.month, widget.activity.checkInTime.day, _checkIn.hour, _checkIn.minute);
    final outDt = DateTime(widget.activity.checkOutTime.year, widget.activity.checkOutTime.month, widget.activity.checkOutTime.day, _checkOut.hour, _checkOut.minute);

    context.read<ScheduleBloc>().add(UpdateActivityEvent(
      activityId: widget.activity.id,
      request: UpdateActivityRequest(
        placeName: _placeCtrl.text.trim(),
        location: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        checkInTime: inDt,
        checkOutTime: outDt,
      ),
    ));
  }

  Widget _buildOrderIndexPicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                final next = _orderIndex - 1;
                _orderIndex = next < 0 ? 0 : next;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
            ),
            child: const Icon(Icons.remove, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Thứ tự: $_orderIndex',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _orderIndex = _orderIndex + 1;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
            ),
            child: const Icon(Icons.add, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}


