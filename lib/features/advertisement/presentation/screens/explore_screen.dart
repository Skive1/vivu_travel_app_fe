import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      // Packages tab selected, load packages if not already loaded
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.userEntity?.roleName == 'Partner') {
        final currentState = context.read<AdvertisementBloc>().state;
        if (currentState is! PackagesLoaded && currentState is! AdvertisementLoading) {
          context.read<AdvertisementBloc>().add(const LoadAllPackages());
        }
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
    context.read<AdvertisementBloc>().add(const LoadAllPosts());
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
      backgroundColor: Colors.grey[50],
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
          setState(() {
            _isLoading = state is AdvertisementLoading;
          });
        },
        builder: (context, state) {
          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
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
                              // Load packages if not already loaded
                              if (state is! PackagesLoaded && state is! AdvertisementLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  context.read<AdvertisementBloc>().add(const LoadAllPackages());
                                });
                              }
                              
                              return RefreshIndicator(
                                onRefresh: () async => _onRefresh(),
                                child: PackageListWidget(
                                  packages: state is PackagesLoaded
                                      ? state.packages
                                      : [],
                                  isLoading: state is AdvertisementLoading,
                                ),
                              );
                            } else {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Chỉ dành cho đối tác',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Bạn cần có tài khoản đối tác để xem các gói dịch vụ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
              // Floating Action Button for Partners
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated &&
                      authState.userEntity?.roleName == 'Partner') {
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
                      child: CreatePostButton(
                        onTap: () => _showCreatePostDialog(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              LoadingOverlay(isLoading: _isLoading),
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
