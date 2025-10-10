import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/schedule_container.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../bloc/schedule_state.dart';

class ScheduleContent extends StatefulWidget {
  final String? scheduleId;
  final VoidCallback? onBack;

  const ScheduleContent({super.key, this.scheduleId, this.onBack});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> 
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasLoadedActivities = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Đảm bảo widget vẫn mounted trước khi start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        // Load activities khi widget được tạo (chỉ một lần)
        if (!_hasLoadedActivities && 
            widget.scheduleId != null && 
            widget.scheduleId!.isNotEmpty) {
          _hasLoadedActivities = true;
          context.read<ScheduleBloc>().add(
            GetActivitiesByScheduleEvent(scheduleId: widget.scheduleId!),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      _fadeController.dispose();
    }
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: AppColors.background,
      child: Column(
        children: [
        // AppBar with SafeArea
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: const BoxDecoration(
              color: AppColors.background,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                  onPressed: widget.onBack,
                ),
                const Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Calendar
        ScheduleCalendar(
          onDateSelected: _onDateSelected,
        ),
        
        // Main content
        Expanded(
          child: BlocBuilder<ScheduleBloc, ScheduleState>(
            builder: (context, state) {
              final isLoading = state is CreateActivityLoading ||
                  state is UpdateActivityLoading ||
                  state is DeleteActivityLoading ||
                  state is CreateScheduleLoading ||
                  state is UpdateScheduleLoading;
              return Stack(
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScheduleContainer(
                        scheduleId: widget.scheduleId,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ),
                  LoadingOverlay(isLoading: isLoading),
                ],
              );
            },
          ),
        ),
      ],
    ),
    );
  }
}