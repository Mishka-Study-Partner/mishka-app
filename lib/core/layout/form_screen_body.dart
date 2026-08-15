import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Scrollable body — **full width** on all devices; extra side inset on tablet only.
class FormScreenBody extends StatelessWidget {
  const FormScreenBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final horizontal = AppBreakpoints.isTablet(context)
        ? AppScale.w(28)
        : AppSizes.paddingMedium;

    return SingleChildScrollView(
      padding: padding ??
          EdgeInsetsDirectional.only(
            start: horizontal,
            end: horizontal,
            bottom: AppSizes.paddingMedium + AppSizes.screenEndPadding,
          ),
      child: child,
    );
  }

  /// Usable width after tablet side inset (full width on phone).
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isCompact(context)) return width;
    return width - AppScale.w(56);
  }

  /// Full-width on tablet — only adds horizontal inset, never a narrow column.
  static Widget constrain(
    BuildContext context,
    Widget child, {
    double? maxWidth,
  }) {
    if (AppBreakpoints.isCompact(context)) return child;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppScale.w(28)),
      child: child,
    );
  }
}
