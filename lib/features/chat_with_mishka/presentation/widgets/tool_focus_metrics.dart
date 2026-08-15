import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Compact chrome around study tools so the tool content is the focus.
class ToolFocusMetrics {
  ToolFocusMetrics._();

  static bool isTablet(BuildContext context) =>
      AppBreakpoints.isTablet(context);

  // —— Chrome (headers, footers, labels) — smaller than tool body ——

  static double chromeTitleSize(BuildContext context) =>
      isTablet(context) ? AppSizes.fontSizeSmall : 12.sp;

  static double chromeLabelSize(BuildContext context) =>
      isTablet(context) ? AppScale.sp(11) : 10.sp;

  static double chromeBodySize(BuildContext context) =>
      isTablet(context) ? AppScale.sp(11) : 11.sp;

  static double chromeIconSize(BuildContext context) =>
      isTablet(context) ? AppScale.w(16) : 16.sp;

  static double chromeGap(BuildContext context) =>
      isTablet(context) ? 3.h : 4.h;

  static double sectionGap(BuildContext context) =>
      isTablet(context) ? 6.h : 6.h;

  static double footerMetaSize(BuildContext context) => 9.sp;

  static double progressLabelSize(BuildContext context) => 10.sp;

  static EdgeInsets navButtonPadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: isTablet(context) ? 12.w : 14.w,
        vertical: isTablet(context) ? 4.h : 5.h,
      );

  static double navButtonFontSize(BuildContext context) => 11.sp;

  /// Gold chips (View details) and full-width Done on play screens.
  static double actionButtonFontSize(BuildContext context) =>
      AppSizes.fontSizeMedium;

  static double doneButtonVerticalPad(BuildContext context) =>
      isTablet(context) ? 8.h : 8.h;

  static double doneButtonFontSize(BuildContext context) =>
      actionButtonFontSize(context);

  static EdgeInsets playScreenPadding(BuildContext context) {
    final horizontal =
        isTablet(context) ? AppScale.w(14) : AppSizes.paddingMedium;
    final vertical = isTablet(context) ? AppScale.h(8) : 10.h;
    return EdgeInsets.fromLTRB(horizontal, vertical, horizontal, vertical);
  }

  static EdgeInsets materialCardHeaderPadding(BuildContext context) =>
      EdgeInsets.fromLTRB(10.w, 6.h, 2.w, 0);

  static EdgeInsets materialCardBodyPadding(BuildContext context) =>
      EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 6.h);

  static double materialCardTitleSize(BuildContext context) => 12.sp;

  static double materialCardActionIconSize(BuildContext context) => 18.sp;

  // —— Tool body heights (chat embedded) ——

  static double embeddedFlashcardHeight(BuildContext context) {
    if (isTablet(context)) return 520.h;
    return 300.h;
  }

  static double embeddedMindmapHeight(BuildContext context) {
    if (isTablet(context)) return 500.h;
    return 360.h;
  }

  static double embeddedSummaryMaxHeight(BuildContext context) {
    if (isTablet(context)) return 420.h;
    return 280.h;
  }

  // —— Community chat embedded (slightly wider bubble, a bit shorter tool) ——

  static double communityEmbeddedFlashcardHeight(BuildContext context) {
    if (isTablet(context)) return 460.h;
    return 300.h;
  }

  static double communityEmbeddedMindmapHeight(BuildContext context) {
    if (isTablet(context)) return 440.h;
    return 360.h;
  }

  static double communityEmbeddedSummaryMaxHeight(BuildContext context) {
    if (isTablet(context)) return 360.h;
    return 280.h;
  }

  // —— Flashcard card internals ——

  /// Small book badge at top of card — not a full-width image strip.
  static double flashcardIconContainerSize(
    BuildContext context, {
    required bool large,
  }) {
    if (isTablet(context)) return AppScale.w(large ? 56 : 50);
    return AppScale.w(large ? 52 : 46);
  }

  static double flashcardCardTextSize(BuildContext context, {required bool large}) =>
      large
          ? (isTablet(context) ? 18.sp : 17.sp)
          : (isTablet(context) ? 13.sp : 12.sp);

  /// Book placeholder inside the small badge — width-based so it stays stable on
  /// Samsung/Android when system font scaling is enabled (unlike `.sp`).
  static double flashcardPlaceholderIconSize(
    BuildContext context, {
    required bool large,
  }) {
    if (isTablet(context)) return AppScale.w(large ? 30 : 26);
    return AppScale.w(large ? 28 : 24);
  }

  /// Mini preview tiles in saved flashcard list rows.
  static double flashcardPreviewTileIconSize(BuildContext context) =>
      isTablet(context) ? AppScale.w(14) : AppScale.w(12);

  /// List-row mini preview tiles (saved flashcards hub).
  static double listPreviewTileHeight(BuildContext context) =>
      isTablet(context) ? AppScale.h(150) : 130.h;

  // Legacy flex helpers — kept so older flashcard layouts still compile during hot reload.
  static int flashcardImageFlex({required bool large}) => large ? 5 : 4;

  static int flashcardTextFlex({required bool large}) => large ? 2 : 3;
}
