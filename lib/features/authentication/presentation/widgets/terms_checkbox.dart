import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class TermsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  
  const TermsCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.responsive(
            verySmall: 16.0,
            small: 18.0,
            large: 20.0,
          ),
          height: context.responsive(
            verySmall: 16.0,
            small: 18.0,
            large: 20.0,
          ),
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: const Color(0xFF24BAEC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 2.0,
                small: 3.0,
                large: 4.0,
              )),
            ),
          ),
        ),
        SizedBox(width: context.responsiveSpacing(
          verySmall: 6.0,
          small: 7.0,
          large: 8.0,
        )),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 10.0,
                  small: 11.0,
                  large: 12.0,
                ),
                color: const Color(0xFF666666),
              ),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Color(0xFF24BAEC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF24BAEC),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
