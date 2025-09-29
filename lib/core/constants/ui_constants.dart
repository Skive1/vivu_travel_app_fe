import 'package:flutter/material.dart';

/// UI constants for consistent design
/// Spacing, sizing, and other UI-related constants

class UIConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;
  
  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;
  
  // Button heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;
  static const double buttonHeightXL = 60.0;
  
  // Input field heights
  static const double inputHeightS = 40.0;
  static const double inputHeightM = 48.0;
  static const double inputHeightL = 56.0;
  
  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  static const double cardPadding = 16.0;
  
  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 80.0;
  
  // Bottom navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;
  
  // Tab bar
  static const double tabBarHeight = 48.0;
  static const double tabIndicatorHeight = 2.0;
  
  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerThicknessThick = 2.0;
  
  // Avatar sizes
  static const double avatarXS = 24.0;
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 56.0;
  static const double avatarXL = 80.0;
  static const double avatarXXL = 120.0;
  
  // Image aspect ratios
  static const double aspectRatio16_9 = 16 / 9;
  static const double aspectRatio4_3 = 4 / 3;
  static const double aspectRatio1_1 = 1.0;
  static const double aspectRatio3_2 = 3 / 2;
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);
  
  // Animation curves
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounceIn = Curves.bounceIn;
  static const Curve curveBounceOut = Curves.bounceOut;
  
  // Screen breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Grid columns
  static const int gridColumnsMobile = 1;
  static const int gridColumnsTablet = 2;
  static const int gridColumnsDesktop = 3;
  
  // List item heights
  static const double listItemHeightS = 48.0;
  static const double listItemHeightM = 64.0;
  static const double listItemHeightL = 80.0;
  
  // Modal dimensions
  static const double modalMaxWidth = 400.0;
  static const double modalMaxHeight = 600.0;
  static const double modalMinHeight = 200.0;
  
  // Toast dimensions
  static const double toastHeight = 48.0;
  static const double toastMaxWidth = 300.0;
  
  // Loading indicator
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorSizeLarge = 48.0;
  
  // Progress bar
  static const double progressBarHeight = 4.0;
  static const double progressBarHeightThick = 8.0;
  
  // Chip dimensions
  static const double chipHeight = 32.0;
  static const double chipPadding = 12.0;
  
  // Badge dimensions
  static const double badgeSize = 16.0;
  static const double badgeSizeLarge = 20.0;
  
  // Floating action button
  static const double fabSize = 56.0;
  static const double fabSizeSmall = 40.0;
  static const double fabSizeLarge = 64.0;
  
  // Search bar
  static const double searchBarHeight = 48.0;
  static const double searchBarRadius = 24.0;
  
  // Bottom sheet
  static const double bottomSheetMaxHeight = 0.9;
  static const double bottomSheetMinHeight = 0.3;
  
  // Drawer
  static const double drawerWidth = 280.0;
  static const double drawerWidthLarge = 320.0;
  
  // Tooltip
  static const double tooltipMaxWidth = 200.0;
  static const Duration tooltipDelay = Duration(milliseconds: 500);
  
  // Snackbar
  static const double snackbarHeight = 48.0;
  static const Duration snackbarDuration = Duration(seconds: 3);
  
  // Page indicator
  static const double pageIndicatorSize = 8.0;
  static const double pageIndicatorSpacing = 8.0;
  
  // Rating
  static const double ratingSize = 20.0;
  static const double ratingSizeLarge = 24.0;
  
  // Checkbox/Radio
  static const double checkboxSize = 20.0;
  static const double radioSize = 20.0;
  
  // Switch
  static const double switchWidth = 48.0;
  static const double switchHeight = 28.0;
  
  // Slider
  static const double sliderHeight = 20.0;
  static const double sliderThumbSize = 20.0;
  
  // Stepper
  static const double stepperHeight = 48.0;
  static const double stepperIconSize = 24.0;
  
  // Timeline
  static const double timelineLineWidth = 2.0;
  static const double timelineIconSize = 24.0;
  
  // Expansion tile
  static const double expansionTileHeight = 48.0;
  static const double expansionTileIconSize = 24.0;
  
  // Data table
  static const double dataTableRowHeight = 48.0;
  static const double dataTableHeaderHeight = 56.0;
  
  // Calendar
  static const double calendarDaySize = 40.0;
  static const double calendarWeekHeight = 48.0;
  
  // Chart
  static const double chartHeight = 200.0;
  static const double chartHeightLarge = 300.0;
  
  // Map
  static const double mapHeight = 200.0;
  static const double mapHeightLarge = 300.0;
  
  // Video player
  static const double videoPlayerHeight = 200.0;
  static const double videoPlayerHeightLarge = 300.0;
  
  // Image carousel
  static const double carouselHeight = 200.0;
  static const double carouselHeightLarge = 300.0;
  
  // Banner
  static const double bannerHeight = 120.0;
  static const double bannerHeightLarge = 200.0;
  
  // Card grid
  static const double cardGridSpacing = 16.0;
  static const double cardGridAspectRatio = 1.2;
  
  // List spacing
  static const double listSpacing = 8.0;
  static const double listSpacingLarge = 16.0;
  
  // Section spacing
  static const double sectionSpacing = 24.0;
  static const double sectionSpacingLarge = 32.0;
  
  // Container padding
  static const double containerPadding = 16.0;
  static const double containerPaddingLarge = 24.0;
  
  // Screen padding
  static const double screenPadding = 16.0;
  static const double screenPaddingLarge = 24.0;
  
  // Safe area padding
  static const double safeAreaPadding = 16.0;
  static const double safeAreaPaddingLarge = 24.0;
}
