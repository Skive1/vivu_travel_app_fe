import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import 'profile_avatar.dart';
import 'profile_user_info.dart';
import 'profile_stats_section.dart';
import 'profile_menu_section.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ProfileContent(
            topPadding: safePadding.top,
            authState: state,
          );
        },
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final double topPadding;
  final AuthState authState;
  
  const ProfileContent({
    super.key,
    required this.topPadding,
    required this.authState,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Column(
      children: [
        // Top safe area spacer
        SizedBox(height: topPadding),
        
        // Header với back button và title
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFF0F0F0),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // Refresh user profile
                  context.read<AuthBloc>().add(GetUserProfileRequested());
                },
                icon: const Icon(
                  Icons.refresh_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        
        // Content body
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<AuthBloc>().add(GetUserProfileRequested());
              // Wait a bit for the request to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                    child: Column(
                      children: [
                        // Avatar
                        ProfileAvatar(
                          user: authState is AuthAuthenticated ? (authState as AuthAuthenticated).userEntity : null,
                        ),
                        const SizedBox(height: 16),
                        // User Info
                        ProfileUserInfo(
                          user: authState is AuthAuthenticated ? (authState as AuthAuthenticated).userEntity : null,
                        ),
                        // Show loading indicator if refreshing
                        if (authState is AuthLoading) ...[
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Statistics Cards
                  const ProfileStatsSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Menu Items
                  const ProfileMenuSection(),
                  
                  // Bottom safe area spacer
                  SizedBox(height: bottomPadding + 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
