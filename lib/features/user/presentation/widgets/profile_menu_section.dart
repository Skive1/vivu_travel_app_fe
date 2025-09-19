import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../injection_container.dart' as di;
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../../routes.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to login screen and clear all previous routes
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          } else if (state is AuthError) {
            DialogUtils.showErrorDialog(
              context: context,
              title: 'Logout Failed',
              message: state.message,
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const MenuRow(
                icon: Icons.person_outline,
                title: 'Profile',
              ),
              const MenuRow(
                icon: Icons.bookmark_outline,
                title: 'Bookmarked',
              ),
              const MenuRow(
                icon: Icons.travel_explore_outlined,
                title: 'Previous Trips',
              ),
              const MenuRow(
                icon: Icons.settings_outlined,
                title: 'Settings',
              ),
              const MenuRow(
                icon: Icons.info_outline,
                title: 'Version',
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return MenuRow(
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    isLast: true,
                    isLoading: state is AuthLoading,
                    onTap: () => _handleLogout(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await DialogUtils.showConfirmDialog(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmColor: AppColors.error,
    );

    if (confirmed == true && context.mounted) {
      // Trigger logout
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }
}

class MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;
  final bool isLoading;
  final VoidCallback? onTap;

  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.isLast = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(16),
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFF0F0F0),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            if (isLoading && isLast)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLast ? AppColors.error : AppColors.primary,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 28,
                color: isLast ? AppColors.error : AppColors.textSecondary,
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isLast ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: isLast ? AppColors.error : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}