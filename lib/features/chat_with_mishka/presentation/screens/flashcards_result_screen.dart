import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/study_result_screen_scaffold.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_collector.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class FlashcardsResultScreen extends StatelessWidget {
  const FlashcardsResultScreen({
    super.key,
    required this.totalCards,
    required this.sourceId,
  });

  final int totalCards;
  final String sourceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StudyResultScreenScaffold(
      onDone: () async {
        await GamificationBadgeCollector.collect(
          type: GamificationBadgeType.flashcardsComplete,
          sourceType: 'flashcards',
          sourceId: sourceId,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      illustration: Image.asset(
        Assets.imagesFlashcardsReviewed,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.emoji_events_outlined,
          size: 96.sp,
          color: AppColors.mainGold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.congratulation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainGold,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            l10n.flashcardsFinishedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
              height: 1.35,
            ),
          ),
          if (totalCards > 0) ...[
            SizedBox(height: 6.h),
            Text(
              l10n.flashcardProgress(totalCards, totalCards),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 14.sp,
                color: AppColors.greyText,
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Text(
            l10n.keepItUp,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainGold,
            ),
          ),
        ],
      ),
    );
  }
}
