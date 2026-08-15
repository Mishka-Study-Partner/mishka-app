import 'package:flutter/material.dart';

import 'package:mishka_app/core/utils/app_sizes.dart';

/// Padding helpers for scrollable page bodies.
class AppScrollInsets {
  AppScrollInsets._();

  static EdgeInsets page({
    double horizontal = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom + AppSizes.screenEndPadding,
    );
  }

  /// [ListView] / [GridView] padding with standard bottom inset.
  static EdgeInsets list({
    double horizontal = 0,
    double top = 0,
    double bottom = 0,
  }) =>
      page(horizontal: horizontal, top: top, bottom: bottom);
}

/// Trailing space at the bottom of a [Column] inside a scroll view.
class ScreenEndSpacer extends StatelessWidget {
  const ScreenEndSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: AppSizes.screenEndPadding);
  }
}
