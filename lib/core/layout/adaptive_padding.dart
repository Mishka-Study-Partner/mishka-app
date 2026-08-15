import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';

class AdaptivePadding {
  AdaptivePadding._();

  static EdgeInsets screenHorizontal(BuildContext context) {
    final horizontal = AppBreakpoints.horizontalPadding(context, base: 16);
    return EdgeInsets.symmetric(horizontal: AppScale.w(horizontal));
  }

  static EdgeInsets screen(BuildContext context) {
    return screenHorizontal(context).copyWith(
      top: AppScale.h(16),
      bottom: AppScale.h(16),
    );
  }
}
