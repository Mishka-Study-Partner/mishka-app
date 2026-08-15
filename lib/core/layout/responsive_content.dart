import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';

/// Full-width child; optional tablet horizontal inset only.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final horizontal = padding ??
        EdgeInsets.symmetric(
          horizontal: AppBreakpoints.isTablet(context)
              ? AppScale.w(AppBreakpoints.horizontalPadding(context, base: 20))
              : 0,
        );

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: horizontal,
        child: child,
      ),
    );
  }
}

/// @deprecated Use full-width layout; kept for compatibility — no width cap.
class ResponsiveScaffoldBody extends StatelessWidget {
  const ResponsiveScaffoldBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.backgroundColor,
  });

  final Widget child;
  final double? maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      backgroundColor: backgroundColor,
      child: child,
    );
  }
}
