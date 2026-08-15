import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../../../core/utils/app_colors.dart';

/// Shared sizing for account-setting fields (phone values preserved).
class ProfileFieldMetrics {
  ProfileFieldMetrics._();

  static bool isTablet(BuildContext context) =>
      AppBreakpoints.isTablet(context);

  static double labelFontSize(BuildContext context) =>
      isTablet(context) ? AppSizes.fontSizeSmall : 12.0;

  static double valueFontSize(BuildContext context) =>
      isTablet(context) ? AppSizes.fontSizeMedium : 12.0;

  /// Height shared by text fields, gender chips, and boxed info rows.
  static double fieldHeight(BuildContext context) =>
      isTablet(context) ? AppScale.h(40) : 28.h;

  static double labelGap(BuildContext context) =>
      isTablet(context) ? 6.h : 4.0;

  static double sectionGap(BuildContext context) =>
      isTablet(context) ? 14.h : 12.h;

  static double horizontalPad(BuildContext context) =>
      isTablet(context) ? AppScale.w(14) : 12.0;

  static double fieldRadius(BuildContext context) =>
      isTablet(context) ? 8.r : 6.0;

  static Color fieldBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : AppColors.white;
  }

  static Color fieldBorder(BuildContext context) =>
      Theme.of(context).dividerColor;

  static TextStyle labelStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Pridi',
      fontSize: labelFontSize(context),
      fontWeight: FontWeight.w500,
      color: scheme.onSurface.withValues(alpha: 0.9),
    );
  }

  static TextStyle valueStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontFamily: 'Pridi',
      fontSize: valueFontSize(context),
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    );
  }
}
