import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';

/// Chat bubble sizing — full screen width; bubbles use a % of the display.
class ChatLayoutMetrics {
  ChatLayoutMetrics._();

  static const double _phoneBubbleBase = 280;

  static double columnMaxWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double bubbleMaxWidth(
    BuildContext context, {
    double designWidth = _phoneBubbleBase,
  }) {
    final screenW = MediaQuery.sizeOf(context).width;
    final fraction = designWidth / _phoneBubbleBase;

    if (AppBreakpoints.isCompact(context)) {
      return AppScale.w(designWidth);
    }

    return (screenW * 0.52 * fraction).clamp(AppScale.w(300), screenW * 0.62);
  }

  static double historyDrawerWidth(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isCompact(context)) return screenW * 0.82;
    return (screenW * 0.42).clamp(AppScale.w(360), AppScale.w(480));
  }
}
