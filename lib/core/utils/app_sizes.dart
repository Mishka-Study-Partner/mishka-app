import 'package:mishka_app/core/layout/app_scale.dart';

class AppSizes {
  // Padding & Margins
  static double get paddingSmall => AppScale.w(8);
  static double get paddingMedium => AppScale.w(16);
  static double get paddingLarge => AppScale.w(24);
  static double get paddingXLarge => AppScale.w(32);

  // Border Radius
  static double get radiusSmall => AppScale.r(8);
  static double get radiusMedium => AppScale.r(12);
  static double get radiusLarge => AppScale.r(20);
  static double get radiusXLarge => AppScale.r(24);

  // Font Sizes
  static double get fontSizeSmall => AppScale.sp(12);
  static double get fontSizeMedium => AppScale.sp(14);
  static double get fontSizeLarge => AppScale.sp(16);
  static double get fontSizeXLarge => AppScale.sp(18);
  static double get fontSizeXXLarge => AppScale.sp(20);
  static double get fontSizeTitle => AppScale.sp(26);

  // Icon Sizes
  static double get iconSmall => AppScale.w(20);
  static double get iconMedium => AppScale.w(24);
  static double get iconLarge => AppScale.w(32);

  // Button Heights — tall enough for Pridi descenders (g, y, p).
  static double get buttonHeight => AppScale.h(52);
  static double get buttonHeightSmall => AppScale.h(44);

  // App Bar
  static double get appBarHeight => AppScale.h(80);
  static double get appBarBottomHeight => AppScale.h(32);

  /// Small gap after the last item in scrollable screens (not system safe area).
  static double get screenEndPadding => AppScale.h(16);
}
