import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class CreatePostButton extends StatelessWidget {
  final VoidCallback onTap;

  const CreatePostButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          context.responsive(
            verySmall: 25.0,
            small: 28.0,
            large: 30.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: context.responsive(
              verySmall: 8.0,
              small: 10.0,
              large: 12.0,
            ),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          context.responsive(
            verySmall: 25.0,
            small: 28.0,
            large: 30.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            context.responsive(
              verySmall: 25.0,
              small: 28.0,
              large: 30.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(
                verySmall: 16.0,
                small: 18.0,
                large: 20.0,
              ),
              vertical: context.responsive(
                verySmall: 10.0,
                small: 12.0,
                large: 14.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: context.responsiveIconSize(
                    verySmall: 18.0,
                    small: 20.0,
                    large: 22.0,
                  ),
                ),
                SizedBox(
                  width: context.responsive(
                    verySmall: 6.0,
                    small: 8.0,
                    large: 10.0,
                  ),
                ),
                Text(
                  'Tạo bài đăng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.responsiveFontSize(
                      verySmall: 12.0,
                      small: 13.0,
                      large: 14.0,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
