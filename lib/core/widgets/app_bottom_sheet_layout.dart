import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';

/// Consistent bottom sheet sizing — wider readable panel on tablet, full width on phone.
class AppBottomSheetLayout {
  AppBottomSheetLayout._();

  static BoxConstraints sheetConstraints(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (AppBreakpoints.isTablet(context)) {
      final maxWidth = (size.width * 0.62).clamp(480.0, 640.0);
      return BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: size.height * 0.72,
      );
    }
    return BoxConstraints(
      maxWidth: size.width,
      maxHeight: size.height * 0.88,
    );
  }

  static EdgeInsets sheetMargin(BuildContext context) {
    if (AppBreakpoints.isTablet(context)) {
      return EdgeInsets.zero;
    }
    return const EdgeInsets.symmetric(horizontal: 12);
  }

  /// Wrap sheet content with width/height caps and keyboard inset padding.
  static Widget wrap(
    BuildContext context, {
    required Widget child,
    EdgeInsets? margin,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: sheetConstraints(context),
          margin: margin ?? sheetMargin(context),
          child: child,
        ),
      ),
    );
  }
}
