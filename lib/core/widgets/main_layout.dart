import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './app_bottom_nav.dart';
import 'page_manager.dart';
import '../../injection_container.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/notification/presentation/widgets/notification_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final PageManager _pageManager = PageManager();

  @override
  void initState() {
    super.initState();
    _pageManager.setOnScheduleTap(_onScheduleTap);
    _pageManager.setOnScheduleViewTap(_onScheduleViewTap);
    _pageManager.setOnPageChanged(_onPageChanged);
  }

  void _onBottomNavTap(int index) {
    if ((_pageManager.isShowingScheduleDetail || _pageManager.isShowingScheduleView) && index == 2) {
      _pageManager.showScheduleList();
    }
    
    setState(() => _currentIndex = index);
  }

  void _onScheduleTap(dynamic schedule) {
    _pageManager.showScheduleDetail(schedule);
    setState(() => _currentIndex = 2);
  }

  void _onScheduleViewTap(String scheduleId) {
    _pageManager.showScheduleView(scheduleId);
    setState(() => _currentIndex = 2);
  }

  void _onPageChanged() {
    setState(() {
      // Trigger rebuild when page changes
    });
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      drawer: BlocProvider(
        create: (context) => sl<NotificationBloc>(),
        child: const NotificationDrawer(),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pageManager.getPages(context),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        isSmallScreen: isSmallScreen,
      ),
    );
  }
}
