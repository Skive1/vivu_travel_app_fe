import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../data/models/create_schedule_request.dart';
import 'create_schedule_form.dart';
import '../../../../core/utils/dialog_utils.dart';

class CreateScheduleDrawer extends StatefulWidget {
  final String participantId;
  final ScheduleBloc scheduleBloc;
  final VoidCallback? onScheduleCreated;

  const CreateScheduleDrawer({
    Key? key,
    required this.participantId,
    required this.scheduleBloc,
    this.onScheduleCreated, 
  }) : super(key: key);

  @override
  State<CreateScheduleDrawer> createState() => _CreateScheduleDrawerState();
}

class _CreateScheduleDrawerState extends State<CreateScheduleDrawer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController(text: '1');
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isShared = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startLocationController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final drawerHeight = screenHeight * 0.8;
    
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is CreateScheduleSuccess) {
          print('✅ CreateScheduleDrawer: Schedule created successfully');
          Navigator.pop(context);
          await DialogUtils.showSuccessDialog(
            context: context,
            title: 'Tạo lịch trình thành công!',
            message: 'Lịch trình "${state.schedule.title}" đã được tạo.',
            useRootNavigator: true,
          );
          widget.onScheduleCreated?.call();
          print('🔄 CreateScheduleDrawer: Callback called for refresh');
        } else if (state is CreateScheduleError) {
          await DialogUtils.showErrorDialog(
            context: context,
            title: 'Tạo lịch trình thất bại',
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
                      'Tạo lịch trình mới',
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
                child: CreateScheduleForm(
                  formKey: _formKey,
                  titleController: _titleController,
                  startLocationController: _startLocationController,
                  destinationController: _destinationController,
                  notesController: _notesController,
                  participantsController: _participantsController,
                  startDate: _startDate,
                  endDate: _endDate,
                  isShared: _isShared,
                  onStartDateChanged: (date) => setState(() => _startDate = date),
                  onEndDateChanged: (date) => setState(() => _endDate = date),
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
                        final isLoading = state is CreateScheduleLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _createSchedule,
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
                              : const Text('Tạo lịch trình'),
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

  void _createSchedule() {
    if (_formKey.currentState!.validate()) {
      final request = CreateScheduleRequest(
        title: _titleController.text.trim(),
        startLocation: _startLocationController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        participantsCount: int.tryParse(_participantsController.text) ?? 1,
        notes: _notesController.text.trim(),
        isShared: _isShared,
      );

      print('🚀 Creating schedule with data: ${request.toJson()}');
      
      widget.scheduleBloc.add(
        CreateScheduleEvent(request: request),
      );
    } else {
      print('❌ Form validation failed');
    }
  }

  // unused placeholders removed
}
