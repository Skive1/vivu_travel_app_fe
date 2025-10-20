import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../../features/authentication/presentation/bloc/auth_state.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';
import '../widgets/package_list_widget.dart';
import '../widgets/post_list_widget.dart';
import '../widgets/create_post_button.dart';
import '../widgets/explore_app_bar.dart';
import 'create_post_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 tabs for Partner (Posts, Packages, Your Packages). For other roles, still 2.
    final isPartner = context.read<AuthBloc>().state is AuthAuthenticated &&
        (context.read<AuthBloc>().state as AuthAuthenticated).userEntity?.roleName == 'Partner';
    _tabController = TabController(length: isPartner ? 3 : 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  void _onTabChanged() {
    // Avoid triggering during animation; only act when tab has settled
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      // Packages tab selected, load packages if not already loaded
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.userEntity?.roleName == 'Partner') {
        final currentState = context.read<AdvertisementBloc>().state;
        if (currentState is! PackagesLoaded && !(currentState is AdvertisementLoading)) {
          context.read<AdvertisementBloc>().add(const LoadAllPackages());
        }
      }
    } else if (_tabController.index == 2) {
      // Your Packages tab
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.userEntity?.roleName == 'Partner') {
        final currentState = context.read<AdvertisementBloc>().state;
        if (currentState is! PurchasedPackagesLoaded && !(currentState is AdvertisementLoading)) {
          final partnerId = authState.userEntity!.id;
          context.read<AdvertisementBloc>().add(LoadPurchasedPackages(partnerId));
        }
      }
    } else if (_tabController.index == 0) {
      // Posts tab selected, ensure loading posts from API
      final currentState = context.read<AdvertisementBloc>().state;
      if (currentState is! PostsLoaded && !(currentState is AdvertisementLoading)) {
        context.read<AdvertisementBloc>().add(const LoadAllPosts());
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final currentState = context.read<AdvertisementBloc>().state;
    if (currentState is! PostsLoaded && !(currentState is AdvertisementLoading)) {
      context.read<AdvertisementBloc>().add(const LoadAllPosts());
    }
  }

  void _onRefresh() {
    if (_tabController.index == 0) {
      // Posts tab
      context.read<AdvertisementBloc>().add(const RefreshPosts());
    } else if (_tabController.index == 1) {
      // Packages tab
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.userEntity?.roleName == 'Partner') {
        context.read<AdvertisementBloc>().add(const RefreshPackages());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ExploreAppBar(
        tabController: _tabController,
        onRefresh: _onRefresh,
      ),
      body: BlocConsumer<AdvertisementBloc, AdvertisementState>(
        listener: (context, state) {
          if (state is AdvertisementError) {
            DialogUtils.showErrorDialog(
              context: context,
              message: state.message,
            );
          }
          // Handle state changes if needed
        },
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final isPartner = authState is AuthAuthenticated && authState.userEntity?.roleName == 'Partner';

          // Build TabBarView children to match TabController length
          final List<Widget> tabChildren = [
                        // Posts Tab
                        RefreshIndicator(
                          onRefresh: () async => _onRefresh(),
                          child: PostListWidget(
                            posts: state is PostsLoaded ? state.posts : [],
                            isLoading: state is AdvertisementLoading,
                          ),
                        ),
                        // Packages Tab (only for Partners)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState is AuthAuthenticated &&
                                authState.userEntity?.roleName == 'Partner') {
                              return RefreshIndicator(
                                onRefresh: () async => _onRefresh(),
                                child: PackageListWidget(
                                  packages: state is PackagesLoaded
                                      ? state.packages
                                      : [],
                                  isLoading: state is AdvertisementLoading,
                                  onPurchaseSuccess: () {
                                    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
                                    final partnerId = auth.userEntity!.id;
                                    _tabController.animateTo(2);
                                    context.read<AdvertisementBloc>().add(LoadPurchasedPackages(partnerId));
                                  },
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFFF8FAFC),
                                      const Color(0xFFE2E8F0).withOpacity(0.3),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(24),
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.verified_user_outlined,
                                            size: 48,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Chỉ dành cho đối tác',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E293B),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Bạn cần có tài khoản đối tác để xem các gói dịch vụ quảng cáo',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: const Color(0xFF64748B),
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ];

          if (isPartner) {
            tabChildren.add(
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: PackageListWidget(
                      packages: state is PurchasedPackagesLoaded ? state.packages : [],
                      isLoading: state is AdvertisementLoading,
                      showPurchaseButton: false,
                    ),
                  );
                },
              ),
            );
          }

          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: tabChildren,
              ),
              // Floating Action Button for Partners
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated &&
                      authState.userEntity?.roleName == 'Partner' &&
                      _tabController.index == 0) {
                    return Positioned(
                      top: context.responsive(
                        verySmall: 16.0,
                        small: 20.0,
                        large: 24.0,
                      ),
                      right: context.responsive(
                        verySmall: 16.0,
                        small: 20.0,
                        large: 24.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CreatePostButton(
                          onTap: () => _showCreatePostDialog(),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    // Get the current bloc instance from the widget tree
    final bloc = context.read<AdvertisementBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const CreatePostScreen(),
        ),
      ),
    );
  }
}
