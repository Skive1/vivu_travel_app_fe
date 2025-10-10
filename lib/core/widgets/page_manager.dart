import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/screens/home_content.dart';
import '../../features/schedule/presentation/screens/schedule_list_content.dart';
import '../../features/schedule/presentation/screens/schedule_detail_content.dart';
import '../../features/schedule/presentation/screens/schedule_content.dart';
import '../../features/schedule/presentation/bloc/schedule_bloc.dart';
import '../../features/user/presentation/screens/profile_content_widget.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../core/utils/user_storage.dart';
import '../../injection_container.dart' as di;
import '../../features/schedule/domain/entities/schedule_entity.dart';

class PageManager {
  List<Widget>? _pages;
  ScheduleEntity? _currentScheduleDetail;
  String? _currentScheduleId;
  Function(dynamic)? _onScheduleTap;
  Function(String)? _onScheduleViewTap;
  VoidCallback? _onPageChanged;
  late final ScheduleBloc _scheduleBloc;

  List<Widget> getPages(BuildContext context) {
    if (_pages == null) {
      _scheduleBloc = di.sl<ScheduleBloc>();
      
      _pages = [
        // Trang chủ
        const HomeContentWidget(),
        // Khám phá (placeholder)
        const ExplorePage(),
        // Kế hoạch
        BlocProvider.value(
          value: _scheduleBloc,
          child: SchedulePageWrapper(
            onScheduleTap: _onScheduleTap,
            onScheduleViewTap: _onScheduleViewTap,
          ),
        ),
        // Nhắn tin (placeholder)
        const ChatPage(),
        // Hồ sơ
        const ProfileContentWidget(),
      ];
    }
    return _pages!;
  }

  void showScheduleDetail(ScheduleEntity schedule) {
    _currentScheduleDetail = schedule;
    // Tái sử dụng BlocProvider hiện có thay vì tạo mới
    _pages![2] = BlocProvider.value(
      value: _scheduleBloc,
      child: ScheduleDetailContent(
        schedule: schedule,
        onScheduleViewTap: _onScheduleViewTap,
        onBack: () => showScheduleList(),
      ),
    );
    // Thông báo MainLayout cập nhật UI
    _onPageChanged?.call();
  }

  void showScheduleList() {
    _currentScheduleDetail = null;
    _currentScheduleId = null;
    // Tái sử dụng BlocProvider hiện có thay vì tạo mới
    _pages![2] = BlocProvider.value(
      value: _scheduleBloc,
      child: SchedulePageWrapper(
        onScheduleTap: _onScheduleTap,
        onScheduleViewTap: _onScheduleViewTap,
      ),
    );
    // Thông báo MainLayout cập nhật UI
    _onPageChanged?.call();
  }

  void showScheduleView(String scheduleId) {
    _currentScheduleId = scheduleId;
    _currentScheduleDetail = null;
    // Tái sử dụng BlocProvider hiện có thay vì tạo mới
    _pages![2] = BlocProvider.value(
      value: _scheduleBloc,
      child: ScheduleViewWrapper(
        scheduleId: scheduleId,
        onBack: () => showScheduleList(),
      ),
    );
    // Thông báo MainLayout cập nhật UI
    _onPageChanged?.call();
  }

  bool get isShowingScheduleDetail => _currentScheduleDetail != null;
  bool get isShowingScheduleView => _currentScheduleId != null;

  void setOnScheduleTap(Function(dynamic) callback) {
    _onScheduleTap = callback;
  }

  void setOnScheduleViewTap(Function(String) callback) {
    _onScheduleViewTap = callback;
  }

  void setOnPageChanged(VoidCallback callback) {
    _onPageChanged = callback;
  }

  void dispose() {
    _scheduleBloc.close();
  }
}


class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Khám phá',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class SchedulePageWrapper extends StatefulWidget {
  final Function(dynamic)? onScheduleTap;
  final Function(String)? onScheduleViewTap;
  
  const SchedulePageWrapper({
    super.key, 
    this.onScheduleTap,
    this.onScheduleViewTap,
  });

  @override
  State<SchedulePageWrapper> createState() => _SchedulePageWrapperState();
}

class _SchedulePageWrapperState extends State<SchedulePageWrapper> {
  String? _participantId;

  @override
  void initState() {
    super.initState();
    _loadParticipantId();
  }

  Future<void> _loadParticipantId() async {
    try {
      final user = await UserStorage.getUserProfile();
      if (user != null && user.id.isNotEmpty) {
        setState(() => _participantId = user.id);
      }
    } catch (_) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ưu tiên lấy participantId từ AuthBloc nếu có sẵn
    String? participantId = _participantId;
    try {
      final state = BlocProvider.of<AuthBloc>(context, listen: false).state;
      if (state is AuthAuthenticated && state.userEntity?.id != null && state.userEntity!.id.isNotEmpty) {
        participantId = state.userEntity!.id;
      }
    } catch (_) {
      // AuthBloc có thể không có trong context, fallback dùng _participantId
    }

    if (participantId == null || participantId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Kế hoạch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Vui lòng đăng nhập để xem lịch trình',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ScheduleListContent(
      participantId: participantId,
      onScheduleTap: widget.onScheduleTap,
      onScheduleViewTap: widget.onScheduleViewTap,
    );
  }
}

class ScheduleViewWrapper extends StatefulWidget {
  final String scheduleId;
  final VoidCallback onBack;

  const ScheduleViewWrapper({
    super.key,
    required this.scheduleId,
    required this.onBack,
  });

  @override
  State<ScheduleViewWrapper> createState() => _ScheduleViewWrapperState();
}

class _ScheduleViewWrapperState extends State<ScheduleViewWrapper> {
  @override
  Widget build(BuildContext context) {
    return ScheduleContent(
      scheduleId: widget.scheduleId,
      onBack: widget.onBack,
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Nhắn tin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}