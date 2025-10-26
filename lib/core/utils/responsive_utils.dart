import 'package:flutter/material.dart';

/// Utility class for responsive design across different screen sizes
class ResponsiveUtils {
  /// Screen width breakpoints based on Material Design guidelines
  static const double verySmallPhone = 320; // ≤320 dp
  static const double smallPhone = 360; // 320-360 dp
  static const double compactPhone = 374; // 360-374 dp
  static const double mediumPhone = 430; // 374-430 dp
  static const double largePhone = 480; // 430-480 dp (Ultra-large phone)
  static const double smallTablet = 600; // 480-600 dp (Small tablet/phablet)
  static const double tablet = 768; // 600-768 dp (Tablet portrait)
  static const double tabletLandscape = 1024; // 768-1024 dp (Tablet landscape)
  
  /// Screen height breakpoints for tall phones
  static const double tallPhoneHeight = 1500; // Phones with high aspect ratio
  static const double veryTallPhoneHeight = 1600; // Very tall phones like 720x1612

  /// Get screen width from context
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height from context
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is very small phone (≤ 320dp)
  static bool isVerySmallPhone(BuildContext context) {
    return getScreenWidth(context) <= verySmallPhone;
  }

  /// Check if screen is small phone (320-360dp)
  static bool isSmallPhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width > verySmallPhone && width <= smallPhone;
  }

  /// Check if screen is compact phone (360-374dp)
  static bool isCompactPhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width > smallPhone && width <= compactPhone;
  }

  /// Check if screen is medium phone (374-430dp)
  static bool isMediumPhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width > compactPhone && width <= mediumPhone;
  }

  /// Check if screen is large phone (430-480dp) - Ultra-large phone
  static bool isLargePhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width > mediumPhone && width <= largePhone;
  }

  /// Check if screen is small tablet/phablet (480-600dp)
  static bool isSmallTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width > largePhone && width <= smallTablet;
  }

  /// Check if screen is tablet portrait (600-768dp)
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width > smallTablet && width <= tablet;
  }

  /// Check if screen is tablet landscape (768-1024dp)
  static bool isTabletLandscape(BuildContext context) {
    final width = getScreenWidth(context);
    return width > tablet && width <= tabletLandscape;
  }

  /// Check if screen is tall phone (height >= 1500px)
  static bool isTallPhone(BuildContext context) {
    return getScreenHeight(context) >= tallPhoneHeight;
  }

  /// Check if screen is very tall phone (height >= 1600px)
  static bool isVeryTallPhone(BuildContext context) {
    return getScreenHeight(context) >= veryTallPhoneHeight;
  }

  /// Check if screen has high aspect ratio (height/width > 2.0)
  static bool isHighAspectRatio(BuildContext context) {
    final aspectRatio = getScreenHeight(context) / getScreenWidth(context);
    return aspectRatio > 2.0;
  }

  /// Get responsive value based on Material Design breakpoints
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T verySmall,
    required T small,
    required T compact,
    required T medium,
    required T large,
    required T smallTablet,
    required T tablet,
    required T tabletLandscape,
  }) {
    if (isVerySmallPhone(context)) {
      return verySmall;
    } else if (isSmallPhone(context)) {
      return small;
    } else if (isCompactPhone(context)) {
      return compact;
    } else if (isMediumPhone(context)) {
      return medium;
    } else if (isLargePhone(context)) {
      return large;
    } else if (isSmallTablet(context)) {
      return smallTablet;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return tabletLandscape;
    }
  }

  /// Get responsive value with simplified breakpoints (backward compatibility)
  static T getResponsiveValueSimple<T>(
    BuildContext context, {
    required T verySmall,
    required T small,
    required T large,
  }) {
    if (isVerySmallPhone(context)) {
      return verySmall;
    } else if (isSmallPhone(context) || isCompactPhone(context) || isMediumPhone(context)) {
      return small;
    } else {
      return large;
    }
  }

  /// Get responsive value with tall phone support
  /// Returns different values for very small, small, large, and tall screens
  static T getResponsiveValueWithTall<T>(
    BuildContext context, {
    required T verySmall,
    required T small,
    required T large,
    required T tall,
  }) {
    if (isVerySmallPhone(context)) {
      return verySmall;
    } else if (isSmallPhone(context) || isCompactPhone(context) || isMediumPhone(context)) {
      return small;
    } else if (isVeryTallPhone(context)) {
      return tall;
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
      final responsiveAll = getResponsiveValueSimple(
        context,
        verySmall: all * 0.7,
        small: all * 0.85,
        large: all,
      );
      return EdgeInsets.all(responsiveAll);
    }

    final responsiveHorizontal = horizontal != null
        ? getResponsiveValueSimple(
            context,
            verySmall: horizontal * 0.7,
            small: horizontal * 0.85,
            large: horizontal,
          )
        : 0.0;

    final responsiveVertical = vertical != null
        ? getResponsiveValueSimple(
            context,
            verySmall: vertical * 0.7,
            small: vertical * 0.85,
            large: vertical,
          )
        : 0.0;

    return EdgeInsets.only(
      left: left != null
          ? getResponsiveValueSimple(
              context,
              verySmall: left * 0.7,
              small: left * 0.85,
              large: left,
            )
          : responsiveHorizontal,
      right: right != null
          ? getResponsiveValueSimple(
              context,
              verySmall: right * 0.7,
              small: right * 0.85,
              large: right,
            )
          : responsiveHorizontal,
      top: top != null
          ? getResponsiveValueSimple(
              context,
              verySmall: top * 0.7,
              small: top * 0.85,
              large: top,
            )
          : responsiveVertical,
      bottom: bottom != null
          ? getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    final percentage = getResponsiveValueSimple(
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
    final percentage = getResponsiveValueSimple(
      context,
      verySmall: verySmallPercentage,
      small: smallPercentage,
      large: largePercentage,
    );
    return getScreenWidth(context) * percentage;
  }

  /// Get responsive button constraints
  static BoxConstraints getResponsiveButtonConstraints(BuildContext context) {
    final minSize = getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    return getResponsiveValueSimple(
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
    final offset = getResponsiveValueSimple(
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

  /// Get responsive container height based on screen height percentage
  static double getResponsiveContainerHeight(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
  }) {
    return getResponsiveHeightPercentage(
      context,
      verySmallPercentage: verySmallPercentage,
      smallPercentage: smallPercentage,
      largePercentage: largePercentage,
    );
  }

  /// Get responsive container width based on screen width percentage
  static double getResponsiveContainerWidth(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
  }) {
    return getResponsiveWidthPercentage(
      context,
      verySmallPercentage: verySmallPercentage,
      smallPercentage: smallPercentage,
      largePercentage: largePercentage,
    );
  }

  /// Get responsive elevation/shadow
  static double getResponsiveElevation(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValueSimple(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive opacity
  static double getResponsiveOpacity(
    BuildContext context, {
    required double verySmall,
    required double small,
    required double large,
  }) {
    return getResponsiveValueSimple(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive duration for animations
  static Duration getResponsiveDuration(
    BuildContext context, {
    required Duration verySmall,
    required Duration small,
    required Duration large,
  }) {
    return getResponsiveValueSimple(
      context,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive curve for animations
  static Curve getResponsiveCurve(BuildContext context) {
    return context.isVerySmallPhone 
        ? Curves.easeInOut 
        : context.isSmallPhone 
            ? Curves.easeInOutCubic 
            : Curves.easeInOutQuart;
  }

  /// Get responsive image scaling factor
  static double getResponsiveImageScale(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      verySmall: 0.9,
      small: 0.95,
      large: 1.0,
    );
  }

  /// Get responsive image height percentage based on screen size
  static double getResponsiveImageHeightPercentage(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
  }) {
    return getResponsiveValueSimple(
      context,
      verySmall: verySmallPercentage,
      small: smallPercentage,
      large: largePercentage,
    );
  }

  /// Get responsive image height with smart scaling for different screen sizes
  static double getSmartResponsiveImageHeight(
    BuildContext context, {
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
    required double verySmallMinHeight,
    required double verySmallMaxHeight,
    required double smallMinHeight,
    required double smallMaxHeight,
    required double largeMinHeight,
    required double largeMaxHeight,
  }) {
    final screenHeight = getScreenHeight(context);
    double percentage;
    double minHeight;
    double maxHeight;
    
    if (isVerySmallPhone(context)) {
      percentage = verySmallPercentage;
      minHeight = verySmallMinHeight;
      maxHeight = verySmallMaxHeight;
    } else if (isSmallPhone(context) || isCompactPhone(context) || isMediumPhone(context)) {
      percentage = smallPercentage;
      minHeight = smallMinHeight;
      maxHeight = smallMaxHeight;
    } else if (isVeryTallPhone(context)) {
      // Điện thoại rất cao: giảm percentage để tránh overflow
      percentage = verySmallPercentage * 0.8;
      minHeight = largeMinHeight;
      maxHeight = largeMaxHeight;
    } else if (isTallPhone(context)) {
      // Điện thoại cao: giảm nhẹ percentage
      percentage = smallPercentage * 0.9;
      minHeight = largeMinHeight;
      maxHeight = largeMaxHeight * 0.98;
    } else {
      percentage = largePercentage;
      minHeight = largeMinHeight;
      maxHeight = largeMaxHeight;
    }
    
    final calculatedHeight = screenHeight * percentage;
    return calculatedHeight.clamp(minHeight, maxHeight);
  }

  /// Get optimal BoxFit for images based on screen size
  static BoxFit getOptimalImageBoxFit(BuildContext context) {
    final aspectRatio = getScreenHeight(context) / getScreenWidth(context);
    
    // Cho điện thoại có tỷ lệ cao, luôn sử dụng cover để tránh distortion
    if (isVeryTallPhone(context) || isTallPhone(context)) {
      return BoxFit.cover;
    } else if (isVerySmallPhone(context)) {
      return BoxFit.cover;
    } else if (isSmallPhone(context) || isCompactPhone(context) || isMediumPhone(context)) {
      return aspectRatio > 1.8 ? BoxFit.cover : BoxFit.cover;
    } else {
      return BoxFit.cover;
    }
  }

  /// Get optimal image alignment based on screen characteristics
  static Alignment getOptimalImageAlignment(BuildContext context) {
    if (isVeryTallPhone(context) || isTallPhone(context)) {
      return Alignment.center;
    } else {
      return Alignment.topCenter;
    }
  }

  /// Get responsive shadow blur for images
  static double getResponsiveImageShadowBlur(BuildContext context) {
    return getResponsiveValueWithTall(
      context,
      verySmall: 6.0,
      small: 8.0,
      large: 10.0,
      tall: 8.0,
    );
  }

  /// Get responsive shadow offset for images
  static Offset getResponsiveImageShadowOffset(BuildContext context) {
    final offset = getResponsiveValueWithTall(
      context,
      verySmall: 1.0,
      small: 2.0,
      large: 3.0,
      tall: 2.0,
    );
    return Offset(0, offset);
  }

  /// Get responsive image alignment
  static Alignment getResponsiveImageAlignment(BuildContext context) {
    return getResponsiveValueSimple(
      context,
      verySmall: Alignment.center,
      small: Alignment.center,
      large: Alignment.center,
    );
  }
}

/// Extension for easier responsive access
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => ResponsiveUtils.getScreenWidth(this);

  /// Get screen height
  double get screenHeight => ResponsiveUtils.getScreenHeight(this);

  /// Check if very small phone
  bool get isVerySmallPhone => ResponsiveUtils.isVerySmallPhone(this);

  /// Check if small phone
  bool get isSmallPhone => ResponsiveUtils.isSmallPhone(this);

  /// Check if compact phone
  bool get isCompactPhone => ResponsiveUtils.isCompactPhone(this);

  /// Check if medium phone
  bool get isMediumPhone => ResponsiveUtils.isMediumPhone(this);

  /// Check if large phone (Ultra-large phone)
  bool get isLargePhone => ResponsiveUtils.isLargePhone(this);

  /// Check if small tablet/phablet
  bool get isSmallTablet => ResponsiveUtils.isSmallTablet(this);

  /// Check if tablet portrait
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if tablet landscape
  bool get isTabletLandscape => ResponsiveUtils.isTabletLandscape(this);

  /// Check if tall phone
  bool get isTallPhone => ResponsiveUtils.isTallPhone(this);

  /// Check if very tall phone
  bool get isVeryTallPhone => ResponsiveUtils.isVeryTallPhone(this);

  /// Check if high aspect ratio
  bool get isHighAspectRatio => ResponsiveUtils.isHighAspectRatio(this);

  /// Get responsive value
  T responsive<T>({
    required T verySmall,
    required T small,
    required T large,
  }) {
    return ResponsiveUtils.getResponsiveValueSimple<T>(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive value with tall phone support
  T responsiveWithTall<T>({
    required T verySmall,
    required T small,
    required T large,
    required T tall,
  }) {
    return ResponsiveUtils.getResponsiveValueWithTall<T>(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
      tall: tall,
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

  /// Get responsive container height
  double responsiveContainerHeight({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveContainerHeight(
      this,
      verySmallPercentage: verySmall,
      smallPercentage: small,
      largePercentage: large,
    );
  }

  /// Get responsive container width
  double responsiveContainerWidth({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveContainerWidth(
      this,
      verySmallPercentage: verySmall,
      smallPercentage: small,
      largePercentage: large,
    );
  }

  /// Get responsive elevation
  double responsiveElevation({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveElevation(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive opacity
  double responsiveOpacity({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveOpacity(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive duration
  Duration responsiveDuration({
    required Duration verySmall,
    required Duration small,
    required Duration large,
  }) {
    return ResponsiveUtils.getResponsiveDuration(
      this,
      verySmall: verySmall,
      small: small,
      large: large,
    );
  }

  /// Get responsive curve
  Curve get responsiveCurve => ResponsiveUtils.getResponsiveCurve(this);

  /// Get responsive image scale
  double get responsiveImageScale => ResponsiveUtils.getResponsiveImageScale(this);

  /// Get responsive image height percentage
  double responsiveImageHeightPercentage({
    required double verySmall,
    required double small,
    required double large,
  }) {
    return ResponsiveUtils.getResponsiveImageHeightPercentage(
      this,
      verySmallPercentage: verySmall,
      smallPercentage: small,
      largePercentage: large,
    );
  }

  /// Get smart responsive image height
  double smartResponsiveImageHeight({
    required double verySmallPercentage,
    required double smallPercentage,
    required double largePercentage,
    required double verySmallMinHeight,
    required double verySmallMaxHeight,
    required double smallMinHeight,
    required double smallMaxHeight,
    required double largeMinHeight,
    required double largeMaxHeight,
  }) {
    return ResponsiveUtils.getSmartResponsiveImageHeight(
      this,
      verySmallPercentage: verySmallPercentage,
      smallPercentage: smallPercentage,
      largePercentage: largePercentage,
      verySmallMinHeight: verySmallMinHeight,
      verySmallMaxHeight: verySmallMaxHeight,
      smallMinHeight: smallMinHeight,
      smallMaxHeight: smallMaxHeight,
      largeMinHeight: largeMinHeight,
      largeMaxHeight: largeMaxHeight,
    );
  }

  /// Get optimal image BoxFit
  BoxFit get optimalImageBoxFit => ResponsiveUtils.getOptimalImageBoxFit(this);

  /// Get optimal image alignment
  Alignment get optimalImageAlignment => ResponsiveUtils.getOptimalImageAlignment(this);

  /// Get responsive image shadow blur
  double get responsiveImageShadowBlur => ResponsiveUtils.getResponsiveImageShadowBlur(this);

  /// Get responsive image shadow offset
  Offset get responsiveImageShadowOffset => ResponsiveUtils.getResponsiveImageShadowOffset(this);

  /// Get responsive image alignment
  Alignment get responsiveImageAlignment => ResponsiveUtils.getResponsiveImageAlignment(this);
}
