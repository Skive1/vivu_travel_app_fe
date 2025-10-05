import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../data/models/update_schedule_request.dart';
import '../../domain/entities/schedule_entity.dart';
import 'edit_schedule_form.dart';
import '../../../../core/utils/dialog_utils.dart';

class EditScheduleDrawer extends StatefulWidget {
  final ScheduleEntity schedule;
  final ScheduleBloc scheduleBloc;
  final VoidCallback? onScheduleUpdated;

  const EditScheduleDrawer({
    Key? key,
    required this.schedule,
    required this.scheduleBloc,
    this.onScheduleUpdated,
  }) : super(key: key);

  @override
  State<EditScheduleDrawer> createState() => _EditScheduleDrawerState();
}

class _EditScheduleDrawerState extends State<EditScheduleDrawer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController.text = widget.schedule.title;
    _startLocationController.text = widget.schedule.startLocation;
    _destinationController.text = widget.schedule.destination;
    _notesController.text = widget.schedule.notes;
    _startDate = widget.schedule.startDate;
    _endDate = widget.schedule.endDate;
    _isShared = widget.schedule.isShared;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startLocationController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final drawerHeight = screenHeight * 0.8;
    
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is UpdateScheduleSuccess) {
          print('✅ EditScheduleDrawer: Schedule updated successfully');
          final overlayCtx = Navigator.of(context, rootNavigator: true).overlay?.context ?? context;
          if (mounted) Navigator.pop(context);
          await DialogUtils.showSuccessDialog(
            context: overlayCtx,
            title: 'Cập nhật thành công!',
            message: 'Lịch trình đã được cập nhật thành công.',
            useRootNavigator: true,
          );
          widget.onScheduleUpdated?.call();
          print('🔄 EditScheduleDrawer: Callback called for refresh');
        } else if (state is UpdateScheduleError) {
          final overlayCtx = Navigator.of(context, rootNavigator: true).overlay?.context ?? context;
          await DialogUtils.showErrorDialog(
            context: overlayCtx,
            title: 'Cập nhật thất bại',
            message: state.message,
            useRootNavigator: true,
          );
        }
      },
      child: Container(
        height: drawerHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa lịch trình',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: EditScheduleForm(
                  formKey: _formKey,
                  titleController: _titleController,
                  startLocationController: _startLocationController,
                  destinationController: _destinationController,
                  notesController: _notesController,
                  startDate: _startDate,
                  endDate: _endDate,
                  isShared: _isShared,
                  onStartDateChanged: (date) => setState(() {
                    _startDate = date;
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate;
                    }
                  }),
                  onEndDateChanged: (date) => setState(() {
                    _endDate = date.isBefore(_startDate) ? _startDate : date;
                  }),
                  onSharedChanged: (value) => setState(() => _isShared = value),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<ScheduleBloc, ScheduleState>(
                      builder: (context, state) {
                        final isLoading = state is UpdateScheduleLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _updateSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Cập nhật'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSchedule() {
    if (_formKey.currentState!.validate()) {
      final request = UpdateScheduleRequest(
        title: _titleController.text.trim(),
        startLocation: _startLocationController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim(),
        isShared: _isShared,
      );

      print('🚀 Updating schedule with data: ${request.toJson()}');
      
      widget.scheduleBloc.add(
        UpdateScheduleEvent(
          scheduleId: widget.schedule.id,
          request: request,
        ),
      );
    } else {
      print('❌ Form validation failed');
    }
  }

  // Dialogs now handled via DialogUtils in BlocListener
}
