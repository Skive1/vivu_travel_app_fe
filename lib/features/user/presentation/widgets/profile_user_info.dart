import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/user_storage.dart';
import '../../../authentication/domain/entities/user_entity.dart';

class ProfileUserInfo extends StatelessWidget {
  const ProfileUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserEntity?>(
      future: UserStorage.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingUserInfo();
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorUserInfo();
        }
        
        final user = snapshot.data!;
        return _UserInfoContent(user: user);
      },
    );
  }
}

class _UserInfoContent extends StatelessWidget {
  final UserEntity user;
  
  const _UserInfoContent({required this.user});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          user.displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        if (user.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.phoneNumber,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingUserInfo extends StatelessWidget {
  const _LoadingUserInfo();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 180,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _ErrorUserInfo extends StatelessWidget {
  const _ErrorUserInfo();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'User',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Unable to load profile',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}