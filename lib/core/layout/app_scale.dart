import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';

/// Scaling from the 375×812 phone baseline.
///
/// Tablets use **sublinear** scaling so UI grows with the screen but still
/// fills the width — no tiny phone column in the middle of a wide display.
class AppScale {
  AppScale._();

  static const double designWidth = 375;
  static const double designHeight = 812;

  static double get _screenWidth {
    final width = ScreenUtil().screenWidth;
    return width > 0 ? width : designWidth;
  }

  static double get _screenHeight {
    final height = ScreenUtil().screenHeight;
    return height > 0 ? height : designHeight;
  }

  static bool get _isTablet => _screenWidth >= AppBreakpoints.compactMax;

  /// Grows on tablet (~1.9× on iPad Pro) without hitting raw 2.75×.
  static double widthScaleFactor() {
    final raw = _screenWidth / designWidth;
    if (!_isTablet) return raw;
    return 1.0 + (raw - 1.0) * 0.55;
  }

  static double heightScaleFactor() {
    final raw = _screenHeight / designHeight;
    if (!_isTablet) return raw;
    return 1.0 + (raw - 1.0) * 0.5;
  }

  static double textScaleFactor() {
    final raw = _screenWidth / designWidth;
    if (!_isTablet) return raw;
    return 1.0 + (raw - 1.0) * 0.42;
  }

  static double w(double value) => value * widthScaleFactor();

  static double h(double value) => value * heightScaleFactor();

  static double sp(double value) => value * textScaleFactor();

  static double r(double value) => value * widthScaleFactor();
}

/// Prefer these over raw `.w` / `.sp` for new responsive sizing.
extension ResponsiveSizing on num {
  double get rw => AppScale.w(toDouble());

  double get rh => AppScale.h(toDouble());

  double get rsp => AppScale.sp(toDouble());

  double get rr => AppScale.r(toDouble());
}
