import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/create_activity_request.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class AddActivityForm extends StatefulWidget {
  final String scheduleId;
  final DateTime initialDate;

  const AddActivityForm({super.key, required this.scheduleId, required this.initialDate});

  @override
  State<AddActivityForm> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final _placeNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  TimeOfDay? _checkIn;
  TimeOfDay? _checkOut;
  int? _orderIndex;

  @override
  void dispose() {
    _placeNameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _orderIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is CreateActivitySuccess) {
          if (mounted) Navigator.of(context).pop();
          await DialogUtils.showSuccessDialog(
            context: context,
            title: 'Thêm hoạt động thành công',
            message: 'Hoạt động đã được thêm vào lịch trình.',
            useRootNavigator: true,
          );
        } else if (state is CreateActivityError) {
          await DialogUtils.showErrorDialog(
            context: context,
            title: 'Thêm hoạt động thất bại',
            message: state.message,
            useRootNavigator: true,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateActivityLoading;
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
                    'Thêm hoạt động',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placeNameCtrl,
                    decoration: _inputDecoration('Tên địa điểm', Icons.place_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên địa điểm' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: _inputDecoration('Địa chỉ', Icons.location_on_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: _inputDecoration('Mô tả (tuỳ chọn)', Icons.notes_outlined),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Check-in',
                          value: _checkIn,
                          onPick: () async {
                            final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (time != null) setState(() => _checkIn = time);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Check-out',
                          value: _checkOut,
                          onPick: () async {
                            final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (time != null) setState(() => _checkOut = time);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOrderIndexPicker(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add),
                      label: const Text('Thêm hoạt động'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
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

  Widget _buildTimePicker({required String label, required TimeOfDay? value, required VoidCallback onPick}) {
    return OutlinedButton(
      onPressed: onPick,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(value != null ? value.format(context) : label,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn thời gian check-in/out')),
      );
      return;
    }

    final checkIn = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day,
        _checkIn!.hour, _checkIn!.minute);
    final checkOut = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day,
        _checkOut!.hour, _checkOut!.minute);

    final request = CreateActivityRequest(
      placeName: _placeNameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      checkInTime: checkIn,
      checkOutTime: checkOut,
      orderIndex: _orderIndex ?? 1,
      scheduleId: widget.scheduleId,
    );

    context.read<ScheduleBloc>().add(CreateActivityEvent(request: request));
  }

  Widget _buildOrderIndexPicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                final next = (_orderIndex ?? 1) - 1;
                _orderIndex = next < 1 ? 1 : next;
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
              'Thứ tự: ${(_orderIndex ?? 1)}',
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
                _orderIndex = (_orderIndex ?? 1) + 1;
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


