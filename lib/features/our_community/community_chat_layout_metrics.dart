import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/chat_layout_metrics.dart';

/// Community group chat bubble sizing (wider material previews on tablet).
class CommunityChatLayoutMetrics {
  CommunityChatLayoutMetrics._();

  static double bubbleMaxWidth(BuildContext context) {
    return ChatLayoutMetrics.bubbleMaxWidth(context);
  }

  /// Shared Mishka tools in chat — wider on tablet, unchanged on phone.
  static double materialBubbleMaxWidth(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    if (AppBreakpoints.isCompact(context)) {
      return ChatLayoutMetrics.bubbleMaxWidth(context);
    }
    // Screen-fraction bounds only — AppScale.w() can exceed max on large tablets.
    final maxW = screenW * 0.74;
    final minW = screenW * 0.48;
    return (screenW * 0.62).clamp(minW, maxW);
  }
}
