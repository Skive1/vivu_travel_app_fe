import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/user_storage.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../../domain/entities/schedule_entity.dart';
import '../bloc/ScheduleBloc.dart';
import '../bloc/ScheduleEvent.dart';
import '../bloc/ScheduleState.dart';
import '../widgets/schedule_detail_info.dart';
import '../widgets/schedule_qr_code.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final ScheduleEntity schedule;

  const ScheduleDetailScreen({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  int _currentIndex = 2; // Schedule tab is index 2
  String? _currentSharedCode;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentSharedCode = widget.schedule.sharedCode;
  }

  void _shareSchedule() {
    if (_isSharing) return; // Prevent multiple clicks
    
    setState(() {
      _isSharing = true;
    });
    
    context.read<ScheduleBloc>().add(
      ShareScheduleEvent(scheduleId: widget.schedule.id),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khám phá - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 2:
        _navigateToScheduleList();
        break;
      case 3:
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ScheduleBloc>(),
      child: BlocListener<ScheduleBloc, ScheduleState>(
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
                onPressed: _isSharing 
                  ? null 
                  : (_currentSharedCode != null ? () => _showShareDialog(context) : _shareSchedule),
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
                      ScheduleDetailInfo(schedule: widget.schedule),
                      
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
                                  arguments: widget.schedule.id,
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
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mã chia sẻ:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                _currentSharedCode ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gửi mã này cho bạn bè để họ có thể tham gia lịch trình của bạn.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
    Clipboard.setData(ClipboardData(text: _currentSharedCode ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép mã chia sẻ'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}