import 'package:flutter/material.dart';

/// Utility class for responsive design across different screen sizes
class ResponsiveUtils {
  /// Screen width breakpoints
  static const double verySmallScreen = 320; // iPhone SE, Galaxy S5
  static const double smallScreen = 360; // iPhone 6/7/8, Galaxy S6
  static const double mediumScreen = 414; // iPhone 6/7/8 Plus
  static const double largeScreen = 414; // iPhone X/11/12/13/14, Galaxy S8+

  /// Get screen width from context
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height from context
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is very small (< 320px)
  static bool isVerySmallScreen(BuildContext context) {
    return getScreenWidth(context) < verySmallScreen;
  }

  /// Check if screen is small (< 360px)
  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < smallScreen;
  }

  /// Check if screen is medium (< 414px)
  static bool isMediumScreen(BuildContext context) {
    return getScreenWidth(context) < mediumScreen;
  }

  /// Check if screen is large (>= 414px)
  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= largeScreen;
  }

  /// Get responsive value based on screen size
  /// Returns different values for very small, small, and large screens
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T verySmall,
    required T small,
    required T large,
  }) {
    if (isVerySmallScreen(context)) {
      return verySmall;
    } else if (isSmallScreen(context)) {
      return small;
    } else {
      return large;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      final responsiveAll = getResponsiveValue(
        context,
        verySmall: all * 0.7,
        small: all * 0.85,
        large: all,
      );
      return EdgeInsets.all(responsiveAll);
    }

    final responsiveHorizontal = horizontal != null
        ? getResponsiveValue(
            context,
            verySmall: horizontal * 0.7,
            small: horizontal * 0.85,
            large: horizontal,
          )
        : 0.0;

    final responsiveVertical = vertical != null
        ? getResponsiveValue(
            context,
            verySmall: vertical * 0.7,
            small: vertical * 0.85,
            large: vertical,
          )
        : 0.0;

    return EdgeInsets.only(
      left: left != null
          ? getResponsiveValue(
              context,
              verySmall: left * 0.7,
              small: left * 0.85,
              large: left,
            )
          : responsiveHorizontal,
      right: right != null
          ? getResponsiveValue(
              context,
              verySmall: right * 0.7,
              small: right * 0.85,
              large: right,
            )
          : responsiveHorizontal,
      top: top != null
          ? getResponsiveValue(
              context,
              verySmall: top * 0.7,
              small: top * 0.85,
              large: top,
            )
          : responsiveVertical,
      bottom: bottom != null
          ? getResponsiveValue(
              context,
              verySmall: bottom * 0.7,
              small: bottom * 0.85,
              large: bottom,
            )
          : responsiveVertical,
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive height based on screen height percentage
  static double getResponsiveHeightPercentage(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
  }) {
    final screenHeight = getScreenHeight(context);
    final percentage = getResponsiveValue(
      context,
      verySmall: verySmallPercentage,
      small: smallPercentage,
      large: largePercentage,
    );
    return screenHeight * percentage;
  }

  /// Get responsive width based on screen width percentage
  static double getResponsiveWidthPercentage(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
  }) {
    final percentage = getResponsiveValue(
      context,
      verySmall: verySmallPercentage,
      small: smallPercentage,
      large: largePercentage,
    );
    return getScreenWidth(context) * percentage;
  }

  /// Get responsive button constraints
  static BoxConstraints getResponsiveButtonConstraints(BuildContext context) {
    final minSize = getResponsiveValue(
      context,
      verySmall: 32.0,
      small: 36.0,
      large: 40.0,
    );
    return BoxConstraints(
      minWidth: minSize,
      minHeight: minSize,
    );
  }

  /// Get responsive touch target size
  static double getResponsiveTouchTarget(BuildContext context) {
    return getResponsiveValue(
      context,
      verySmall: 36.0,
      small: 40.0,
      large: 48.0,
    );
  }

  /// Get responsive container size
  static double getResponsiveContainerSize(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive shadow blur
  static double getResponsiveShadowBlur(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive shadow offset
  static Offset getResponsiveShadowOffset(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    final offset = getResponsiveValue(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
    return Offset(0, offset);
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return getResponsivePadding(
      context,
      horizontal: horizontal,
      vertical: vertical,
      all: all,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  /// Get responsive SizedBox height
  static Widget getResponsiveSizedBoxHeight(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return SizedBox(
      height: getResponsiveSpacing(
        context,
        verySmall: verySmall,
        small: small,
        large: large,
      ),
    );
  }

  /// Get responsive SizedBox width
  static Widget getResponsiveSizedBoxWidth(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return SizedBox(
      width: getResponsiveSpacing(
        context,
        verySmall: verySmall,
        small: small,
        large: large,
      ),
    );
  }
}

/// Extension for easier responsive access
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => ResponsiveUtils.getScreenWidth(this);

  /// Get screen height
  double get screenHeight => ResponsiveUtils.getScreenHeight(this);

  /// Check if very small screen
  bool get isVerySmallScreen => ResponsiveUtils.isVerySmallScreen(this);

  /// Check if small screen
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);

  /// Check if medium screen
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);

  /// Check if large screen
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);

  /// Get responsive value
  T responsive<T>({
    required T verySmall,
    required T small,
    required T large,
  }) {
    return ResponsiveUtils.getResponsiveValue<T>(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive font size
  double responsiveFontSize({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveFontSize(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive icon size
  double responsiveIconSize({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveIconSize(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive spacing
  double responsiveSpacing({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveSpacing(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive padding
  EdgeInsets responsivePadding({
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return ResponsiveUtils.getResponsivePadding(
      this,
      horizontal: horizontal,
      vertical: vertical,
      all: all,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  /// Get responsive margin
  EdgeInsets responsiveMargin({
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return ResponsiveUtils.getResponsiveMargin(
      this,
      horizontal: horizontal,
      vertical: vertical,
      all: all,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  /// Get responsive border radius
  double responsiveBorderRadius({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveBorderRadius(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive height percentage
  double responsiveHeightPercentage({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveHeightPercentage(
      this,
      verySmallPercentage: verySmall,
      smallPercentage: small,
      largePercentage: large,
    );
  }

  /// Get responsive width percentage
  double responsiveWidthPercentage({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveWidthPercentage(
      this,
      verySmallPercentage: verySmall,
      smallPercentage: small,
      largePercentage: large,
    );
  }
}
