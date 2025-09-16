import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn có 3 thông báo mới'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bellBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.bellBackground,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: SvgPicture.string(
                      '''<svg width="18" height="22" viewBox="0 0 18 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M2.31325 11.9153L1.56803 11.8307L1.56803 11.8307L2.31325 11.9153ZM2.76043 7.97519L3.50565 8.05977L2.76043 7.97519ZM1.44776 13.8721L0.876647 13.386H0.876647L1.44776 13.8721ZM16.4319 11.8307C16.3852 11.4191 16.0137 11.1233 15.6021 11.17C15.1905 11.2168 14.8948 11.5883 14.9415 11.9998L16.4319 11.8307ZM16.5522 13.8721L15.9811 14.3583L16.5522 13.8721ZM6.73002 3.37366L6.97297 4.08322C7.27626 3.97938 7.48002 3.69424 7.48002 3.37366H6.73002ZM10.1539 2.28059C10.4237 2.59487 10.8972 2.6309 11.2115 2.36107C11.5258 2.09125 11.5618 1.61774 11.292 1.30347L10.1539 2.28059ZM12.7023 19.2632C12.8476 18.8753 12.651 18.4431 12.2632 18.2977C11.8753 18.1523 11.443 18.3489 11.2977 18.7368L12.7023 19.2632ZM6.70227 18.7368C6.5569 18.3489 6.12463 18.1523 5.73677 18.2977C5.3489 18.4431 5.15231 18.8753 5.29767 19.2632L6.70227 18.7368ZM14.7772 16.25H3.22278V17.75H14.7772V16.25ZM3.05846 11.9998L3.50565 8.05977L2.01522 7.89061L1.56803 11.8307L3.05846 11.9998ZM2.01886 14.3583C2.59618 13.6801 2.96025 12.8652 3.05846 11.9998L1.56803 11.8307C1.50516 12.3846 1.27064 12.9231 0.876647 13.386L2.01886 14.3583ZM14.9415 11.9998C15.0397 12.8652 15.4038 13.6801 15.9811 14.3583L17.1233 13.386C16.7293 12.9231 16.4948 12.3846 16.4319 11.8307L14.9415 11.9998ZM3.22278 16.25C2.56774 16.25 2.1044 15.926 1.89053 15.5492C1.68406 15.1854 1.68711 14.748 2.01886 14.3583L0.876647 13.386C0.111376 14.285 0.0877426 15.4116 0.585954 16.2895C1.07676 17.1544 2.04944 17.75 3.22278 17.75V16.25ZM14.7772 17.75C15.9505 17.75 16.9232 17.1544 17.414 16.2895C17.9122 15.4116 17.8886 14.285 17.1233 13.386L15.9811 14.3583C16.3128 14.748 16.3159 15.1854 16.1094 15.5492C15.8955 15.926 15.4322 16.25 14.7772 16.25V17.75ZM7.48002 3.37366V3.26995H5.98002V3.37366H7.48002ZM3.50565 8.05977C3.70867 6.27101 5.05584 4.73962 6.97297 4.08322L6.48708 2.6641C4.11941 3.47476 2.29446 5.43026 2.01522 7.89061L3.50565 8.05977ZM8.99997 0.25C7.3321 0.25 5.98002 1.60208 5.98002 3.26995H7.48002C7.48002 2.4305 8.16053 1.75 8.99997 1.75V0.25ZM8.99997 1.75C9.46128 1.75 9.874 1.95459 10.1539 2.28059L11.292 1.30347C10.7393 0.659712 9.91706 0.25 8.99997 0.25V1.75ZM11.2977 18.7368C10.975 19.5979 10.0846 20.25 8.99997 20.25V21.75C10.6854 21.75 12.1516 20.7325 12.7023 19.2632L11.2977 18.7368ZM8.99997 20.25C7.91539 20.25 7.02498 19.5979 6.70227 18.7368L5.29767 19.2632C5.84832 20.7325 7.31449 21.75 8.99997 21.75V20.25Z" fill="#1B1E28"/>
</svg>''',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  
                  // Notification badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}