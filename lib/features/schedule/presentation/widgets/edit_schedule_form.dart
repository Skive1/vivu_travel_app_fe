import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class EditScheduleForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController startLocationController;
  final TextEditingController destinationController;
  final TextEditingController notesController;
  final DateTime startDate;
  final DateTime endDate;
  final bool isShared;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<bool> onSharedChanged;

  const EditScheduleForm({
    Key? key,
    required this.formKey,
    required this.titleController,
    required this.startLocationController,
    required this.destinationController,
    required this.notesController,
    required this.startDate,
    required this.endDate,
    required this.isShared,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onSharedChanged,
  }) : super(key: key);

  @override
  State<EditScheduleForm> createState() => _EditScheduleFormState();
}

class _EditScheduleFormState extends State<EditScheduleForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _buildSectionTitle('Thông tin cơ bản'),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: widget.titleController,
            label: 'Tên lịch trình',
            hint: 'Nhập tên lịch trình',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên lịch trình';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Location
          _buildTextField(
            controller: widget.startLocationController,
            label: 'Điểm khởi hành',
            hint: 'Nhập điểm khởi hành',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập điểm khởi hành';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: widget.destinationController,
            label: 'Điểm đến',
            hint: 'Nhập điểm đến',
            icon: Icons.place_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập điểm đến';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Date and Time
          _buildSectionTitle('Thời gian'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Ngày bắt đầu',
                  date: widget.startDate,
                  onTap: () => _selectDate(context, widget.startDate, widget.onStartDateChanged),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'Ngày kết thúc',
                  date: widget.endDate,
                  onTap: () => _selectDate(context, widget.endDate, widget.onEndDateChanged),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Settings
          _buildSectionTitle('Cài đặt'),
          const SizedBox(height: 16),
          
          // Shared toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.share_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chia sẻ lịch trình',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cho phép người khác tham gia lịch trình này',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.isShared,
                  onChanged: widget.onSharedChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes
          _buildTextField(
            controller: widget.notesController,
            label: 'Ghi chú (tùy chọn)',
            hint: 'Nhập ghi chú cho lịch trình',
            icon: Icons.note_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onDateChanged,
  ) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5, 1, 1);
    final last = DateTime(now.year + 5, 12, 31);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != initialDate) {
      onDateChanged(picked);
    }
  }
}
