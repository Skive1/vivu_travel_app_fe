import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/user_storage.dart';
import '../../../../injection_container.dart';
import '../bloc/schedule_bloc.dart';
import '../widgets/schedule_container.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../bloc/schedule_state.dart';

class ScheduleScreen extends StatefulWidget {
  final String? scheduleId;

  const ScheduleScreen({super.key, this.scheduleId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void _navigateToScheduleList() async {
    try {
      final user = await UserStorage.getUserProfile();
      if (user != null && user.id.isNotEmpty) {
        Navigator.pushReplacementNamed(
          context, 
          '/schedule-list',
          arguments: user.id,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để xem lịch trình'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy thông tin người dùng'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => sl<ScheduleBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Lịch trình chi tiết',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: _navigateToScheduleList,
          ),
        ),
        body: BlocBuilder<ScheduleBloc, ScheduleState>(
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
                    child: ScheduleContainer(scheduleId: widget.scheduleId),
                  ),
                ),
                LoadingOverlay(isLoading: isLoading),
              ],
            );
          },
        ),
      ),
    );
  }
}
