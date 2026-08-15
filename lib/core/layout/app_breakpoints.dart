import 'package:flutter/material.dart';

/// Mishka width buckets for responsive layouts.
///
/// | Bucket   | Width        |
/// |----------|--------------|
/// | compact  | &lt; 600       | phone
/// | medium   | 600 – 840    | small tablet
/// | expanded | 840 – 1200   | large tablet / iPad
/// | desktop  | ≥ 1200       | desktop / wide iPad landscape
enum AppBreakpoint {
  compact,
  medium,
  expanded,
  desktop,
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double compactMax = 600;
  static const double mediumMax = 840;
  static const double expandedMax = 1200;

  static AppBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ofWidth(width);
  }

  static AppBreakpoint ofWidth(double width) {
    if (width < compactMax) return AppBreakpoint.compact;
    if (width < mediumMax) return AppBreakpoint.medium;
    if (width < expandedMax) return AppBreakpoint.expanded;
    return AppBreakpoint.desktop;
  }

  /// Phone layout.
  static bool isCompact(BuildContext context) =>
      of(context) == AppBreakpoint.compact;

  /// Tablet and larger (width ≥ 600).
  static bool isTablet(BuildContext context) => !isCompact(context);

  /// Small tablet only (600 – 840).
  static bool isMedium(BuildContext context) =>
      of(context) == AppBreakpoint.medium;

  /// Large tablet / iPad (840 – 1200).
  static bool isExpanded(BuildContext context) =>
      of(context) == AppBreakpoint.expanded;

  /// Desktop / very wide layouts (≥ 1200).
  static bool isDesktop(BuildContext context) =>
      of(context) == AppBreakpoint.desktop;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Grid columns by breakpoint — override per screen as needed.
  static int gridCrossAxisCount(
    BuildContext context, {
    int phone = 1,
    int smallTablet = 2,
    int largeTablet = 2,
    int desktop = 3,
  }) {
    return switch (of(context)) {
      AppBreakpoint.compact => phone,
      AppBreakpoint.medium => smallTablet,
      AppBreakpoint.expanded => largeTablet,
      AppBreakpoint.desktop => desktop,
    };
  }

  /// Horizontal screen padding grows on larger breakpoints.
  static double horizontalPadding(BuildContext context, {double base = 16}) {
    return switch (of(context)) {
      AppBreakpoint.compact => base,
      AppBreakpoint.medium => base * 1.35,
      AppBreakpoint.expanded => base * 1.6,
      AppBreakpoint.desktop => base * 1.85,
    };
  }
}
