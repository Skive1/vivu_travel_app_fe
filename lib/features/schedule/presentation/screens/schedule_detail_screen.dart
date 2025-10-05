import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../widgets/schedule_detail_info.dart';
import '../widgets/schedule_qr_code.dart';
import '../widgets/edit_schedule_drawer.dart';
import 'package:flutter/services.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final ScheduleEntity schedule;

  const ScheduleDetailScreen({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> with AutomaticKeepAliveClientMixin {
  late ScheduleEntity _currentSchedule;
  String? _currentSharedCode;
  bool _isSharing = false;
  int _currentIndex = 2; // Schedule tab

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentSchedule = widget.schedule;
    _currentSharedCode = widget.schedule.sharedCode;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Explore (coming soon)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khám phá - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 2:
        // Already on schedule detail
        break;
      case 3:
        // Chat (coming soon)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nhắn tin - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _shareSchedule() {
    if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) {
      // Nếu đã có sharedCode, chỉ hiển thị dialog
      _showShareDialog(context);
    } else {
      // Nếu chưa có sharedCode, tạo mới
      setState(() {
        _isSharing = true;
      });
      
      context.read<ScheduleBloc>().add(
        ShareScheduleEvent(scheduleId: _currentSchedule.id),
      );
    }
  }

  void _showEditScheduleDrawer() {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: EditScheduleDrawer(
          schedule: _currentSchedule,
          scheduleBloc: scheduleBloc,
          onScheduleUpdated: () {
            print('🔄 ScheduleDetailScreen: Callback triggered from EditScheduleDrawer');
            // Chỉ cần clear cache, BLoC sẽ tự động emit state mới
            scheduleBloc.add(const ClearCacheEvent());
          },
        ),
      ),
    );
  }

  void _updateScheduleData(ScheduleEntity newSchedule) {
    print('🔄 ScheduleDetailScreen: Updating schedule data');
    print('🔄 Old title: ${_currentSchedule.title}');
    print('🔄 New title: ${newSchedule.title}');
    print('🔄 Old sharedCode: ${_currentSchedule.sharedCode}');
    print('🔄 New sharedCode: ${newSchedule.sharedCode}');
    
    setState(() {
      _currentSchedule = newSchedule;
      _currentSharedCode = newSchedule.sharedCode;
    });
    
    print('✅ ScheduleDetailScreen: Schedule data updated');
    print('✅ Current title after update: ${_currentSchedule.title}');
    print('✅ Current sharedCode after update: ${_currentSharedCode}');
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mã chia sẻ của bạn:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _currentSharedCode ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gửi mã này cho người khác để họ có thể xem lịch trình của bạn.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copySharedCode(context);
            },
            child: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  void _copySharedCode(BuildContext context) {
    if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _currentSharedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép mã chia sẻ'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ShareScheduleLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Đang tạo mã chia sẻ...'),
                ],
              ),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is ShareScheduleSuccess) {
          setState(() {
            _currentSharedCode = state.sharedCode;
            _isSharing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo mã chia sẻ thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ShareScheduleError) {
          setState(() {
            _isSharing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi chia sẻ: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is UpdateScheduleSuccess) {
          print('🔄 ScheduleDetailScreen: Update success, updating UI with new data');
          _updateScheduleData(state.schedule);
          print('✅ ScheduleDetailScreen: UI updated with new schedule data');
          print('✅ New schedule title: ${_currentSchedule.title}');
          print('✅ New shared code: ${_currentSharedCode}');
        } else if (state is ScheduleLoaded) {
          print('🔄 ScheduleDetailScreen: Schedules refreshed from server');
          // Tìm schedule hiện tại trong danh sách mới và update nếu có thay đổi
          try {
            final updatedSchedule = state.schedules.firstWhere(
              (schedule) => schedule.id == _currentSchedule.id,
            );
            print('✅ ScheduleDetailScreen: Found schedule in refreshed list');
            print('🔄 Old title: ${_currentSchedule.title}');
            print('🔄 New title: ${updatedSchedule.title}');
            print('🔄 Old sharedCode: ${_currentSchedule.sharedCode}');
            print('🔄 New sharedCode: ${updatedSchedule.sharedCode}');
            
            // Update UI với data mới
            _updateScheduleData(updatedSchedule);
            print('✅ ScheduleDetailScreen: UI updated with refreshed data');
          } catch (e) {
            print('⚠️ ScheduleDetailScreen: Schedule not found in refreshed list - $e');
            // Schedule có thể đã bị xóa hoặc không có quyền truy cập
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Chi tiết lịch trình',
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
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: _showEditScheduleDrawer,
            ),
            IconButton(
              icon: _isSharing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : const Icon(Icons.share, color: AppColors.primary),
              onPressed: _isSharing ? null : _shareSchedule,
            ),
          ],
        ),
        body: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Schedule Info Card
                    ScheduleDetailInfo(schedule: _currentSchedule),
                    
                    const SizedBox(height: 24),
                    
                    // QR Code Section (if shared)
                    if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) ...[
                      ScheduleQrCode(sharedCode: _currentSharedCode!),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/schedule',
                                arguments: _currentSchedule.id,
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Xem lịch trình'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copySharedCode(context),
                              icon: const Icon(Icons.copy),
                              label: const Text('Sao chép mã'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareSchedule,
                              icon: const Icon(Icons.share),
                              label: const Text('Tạo mã chia sẻ'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
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
            
            // Bottom navigation
            HomeBottomNav(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
