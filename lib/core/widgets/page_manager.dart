import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/screens/home_content.dart';
import '../../features/schedule/presentation/screens/schedule_list_content.dart';
import '../../features/schedule/presentation/screens/schedule_detail_content.dart';
import '../../features/schedule/presentation/screens/schedule_content.dart';
import '../../features/schedule/presentation/bloc/schedule_bloc.dart';
import '../../features/schedule/presentation/bloc/schedule_state.dart';
import '../../features/schedule/presentation/bloc/schedule_event.dart';
import '../../features/user/presentation/screens/profile_content_widget.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';
import '../../core/utils/user_storage.dart';
import '../../injection_container.dart' as di;
import '../../features/schedule/domain/entities/schedule_entity.dart';
import '../../features/advertisement/presentation/screens/explore_screen.dart';
import '../../features/advertisement/presentation/bloc/advertisement_bloc.dart';
import '../../features/transaction/presentation/screens/transaction_list_screen.dart';
import '../../features/transaction/presentation/screens/transaction_detail_screen.dart';
import '../../features/transaction/presentation/bloc/transaction_bloc.dart';
import '../../features/transaction/domain/entities/transaction_entity.dart';
import '../../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../../features/ai_chat/presentation/bloc/ai_chat_bloc.dart';

class PageManager {
  List<Widget>? _pages;
  ScheduleEntity? _currentScheduleDetail;
  String? _currentScheduleId;
  Function(dynamic)? _onScheduleTap;
  Function(String)? _onScheduleViewTap;
  VoidCallback? _onPageChanged;
  late final ScheduleBloc _scheduleBloc;
  late final AdvertisementBloc _advertisementBloc;
  late final ProfilePageManager _profilePageManager;

  List<Widget> getPages(BuildContext context) {
    if (_pages == null) {
      _scheduleBloc = di.sl<ScheduleBloc>();
      _advertisementBloc = di.sl<AdvertisementBloc>();
      _profilePageManager = ProfilePageManager();
      _profilePageManager.setParentPageManager(this);
      
      _pages = [
        // Trang chủ
        const HomeContentWidget(),
        // Khám phá
        BlocProvider.value(
          value: _advertisementBloc,
          child: const ExploreScreen(),
        ),
        // Kế hoạch
        BlocProvider.value(
          value: _scheduleBloc,
          child: SchedulePageWrapper(
            onScheduleTap: _onScheduleTap,
            onScheduleViewTap: _onScheduleViewTap,
            onScheduleDetailLoaded: updateScheduleDetail,
          ),
        ),
        // AI Chat
        BlocProvider(
          create: (context) => di.sl<AIChatBloc>(),
          child: const AIChatPage(),
        ),
        // Hồ sơ với IndexedStack
        ProfilePageWrapper(
          profilePageManager: _profilePageManager,
        ),
      ];
    }
    return _pages!;
  }

  void showScheduleDetail(ScheduleEntity schedule) {
    _currentScheduleDetail = schedule;
    
    // Preload data while showing UI
    _preloadScheduleData(schedule.id);
    
    // Show UI immediately - let ScheduleDetailContent handle role fetching/caching
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

  void _preloadScheduleData(String scheduleId) {
    // Only preload schedule details, participants will be loaded on demand
    Future.microtask(() {
      _scheduleBloc.add(GetScheduleByIdEvent(scheduleId: scheduleId));
    });
  }

  void updateScheduleDetail(ScheduleEntity schedule) {
    _currentScheduleDetail = schedule;
    // Update the page with the full schedule data
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
        onScheduleDetailLoaded: updateScheduleDetail,
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

  AdvertisementBloc get advertisementBloc => _advertisementBloc;
  ProfilePageManager get profilePageManager => _profilePageManager;

  void showTransactionList() {
    _profilePageManager.showTransactionList();
    _onPageChanged?.call();
  }

  void showTransactionDetail(TransactionEntity transaction) {
    _profilePageManager.showTransactionDetail(transaction);
    _onPageChanged?.call();
  }

  void showProfileMain() {
    _profilePageManager.showProfileMain();
    _onPageChanged?.call();
  }

  void dispose() {
    _scheduleBloc.close();
    _profilePageManager.dispose();
    // Don't close _advertisementBloc as it's a singleton and may be used elsewhere
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
  final Function(ScheduleEntity)? onScheduleDetailLoaded;
  
  const SchedulePageWrapper({
    super.key, 
    this.onScheduleTap,
    this.onScheduleViewTap,
    this.onScheduleDetailLoaded,
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
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is GetScheduleByIdSuccess) {  
          // Call the callback to handle schedule detail update
          widget.onScheduleDetailLoaded?.call(state.schedule);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
        // Lấy participantId ưu tiên từ AuthBloc
        String participantId = '';
        if (authState is AuthAuthenticated &&
            authState.userEntity != null &&
            authState.userEntity!.id.isNotEmpty) {
          participantId = authState.userEntity!.id;
        } else if (_participantId != null && _participantId!.isNotEmpty) {
          participantId = _participantId!;
        }

        if (participantId.isEmpty) {
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
        },
      ),
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


class ProfilePageManager {
  List<Widget>? _profilePages;
  TransactionEntity? _currentTransactionDetail;
  int _currentIndex = 0; // 0: Profile main, 1: Transaction list, 2: Transaction detail
  int _previousIndex = 0; // Track previous index for animation direction
  late final TransactionBloc _transactionBloc;
  PageManager? _parentPageManager;
  VoidCallback? _onPageChanged;

  List<Widget> getProfilePages(BuildContext context) {
    if (_profilePages == null) {
      _transactionBloc = di.sl<TransactionBloc>();
      
      _profilePages = [
        // Profile main page
        ProfileContentWidget(pageManager: _parentPageManager),
        // Transaction list page
        BlocProvider.value(
          value: _transactionBloc,
          child: TransactionListScreen(pageManager: _parentPageManager),
        ),
        // Transaction detail page (placeholder, will be updated when needed)
        const SizedBox.shrink(),
      ];
    } else {
      // Update existing pages with current pageManager reference
      _profilePages![0] = ProfileContentWidget(pageManager: _parentPageManager);
      _profilePages![1] = BlocProvider.value(
        value: _transactionBloc,
        child: TransactionListScreen(pageManager: _parentPageManager),
      );
    }
    return _profilePages!;
  }

  void showProfileMain() {
    _previousIndex = _currentIndex;
    _currentTransactionDetail = null;
    _currentIndex = 0;
    _onPageChanged?.call();
  }

  void showTransactionList() {
    _previousIndex = _currentIndex;
    _currentTransactionDetail = null;
    _currentIndex = 1;
    
    // Ensure _profilePages is initialized
    if (_profilePages == null) {
      _transactionBloc = di.sl<TransactionBloc>();
      _profilePages = [
        ProfileContentWidget(pageManager: _parentPageManager),
        BlocProvider.value(
          value: _transactionBloc,
          child: TransactionListScreen(pageManager: _parentPageManager),
        ),
        const SizedBox.shrink(),
      ];
    } else {
      // Update the transaction list page
      _profilePages![1] = BlocProvider.value(
        value: _transactionBloc,
        child: TransactionListScreen(pageManager: _parentPageManager),
      );
    }
    _onPageChanged?.call();
  }

  void setParentPageManager(PageManager parentPageManager) {
    _parentPageManager = parentPageManager;
    // Update existing pages if they exist
    if (_profilePages != null) {
      _profilePages![0] = ProfileContentWidget(pageManager: _parentPageManager);
      _profilePages![1] = BlocProvider.value(
        value: _transactionBloc,
        child: TransactionListScreen(pageManager: _parentPageManager),
      );
    }
  }

  void showTransactionDetail(TransactionEntity transaction) {
    _previousIndex = _currentIndex;
    _currentTransactionDetail = transaction;
    _currentIndex = 2;
    // Update the transaction detail page
    _profilePages![2] = TransactionDetailScreen(
      transaction: transaction,
      pageManager: _parentPageManager,
    );
    _onPageChanged?.call();
  }

  int get currentProfileIndex => _currentIndex;
  int get previousProfileIndex => _previousIndex;
  
  // Determine animation direction: true = forward (right to left), false = backward (left to right)
  bool get isForwardAnimation => _currentIndex > _previousIndex;

  bool get isShowingTransactionDetail => _currentTransactionDetail != null;

  void dispose() {
    _transactionBloc.close();
  }
}

class ProfilePageWrapper extends StatefulWidget {
  final ProfilePageManager profilePageManager;

  const ProfilePageWrapper({
    super.key,
    required this.profilePageManager,
  });

  @override
  State<ProfilePageWrapper> createState() => _ProfilePageWrapperState();
}

class _ProfilePageWrapperState extends State<ProfilePageWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to page changes and rebuild when needed
    widget.profilePageManager._onPageChanged = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.profilePageManager.currentProfileIndex;
    final pages = widget.profilePageManager.getProfilePages(context);
    final isForward = widget.profilePageManager.isForwardAnimation;
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Determine slide direction based on navigation direction
        final beginOffset = isForward 
            ? const Offset(0.3, 0.0)  // Forward: slide from right (reduced distance)
            : const Offset(-0.3, 0.0); // Backward: slide from left (reduced distance)
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: RepaintBoundary(
        key: ValueKey(currentIndex),
        child: pages[currentIndex],
      ),
    );
  }
}