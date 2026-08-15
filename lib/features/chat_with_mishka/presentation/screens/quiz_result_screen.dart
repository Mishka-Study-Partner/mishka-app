import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/widgets/study_result_screen_scaffold.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_collector.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.percent,
    required this.correctCount,
    required this.totalCount,
    required this.sourceId,
    this.attemptId,
  });

  final int percent;
  final int correctCount;
  final int totalCount;
  final String sourceId;
  final String? attemptId;

  GamificationBadgeType get _badgeType =>
      GamificationBadgeTypeX.quizFromScore(
        correctCount: correctCount,
        totalCount: totalCount,
      );

  bool get _showCongrats =>
      _badgeType != GamificationBadgeType.quizKeepLearning;

  String _badgeAsset() {
    return switch (_badgeType) {
      GamificationBadgeType.quizPerfect => Assets.imagesPerfectScore,
      GamificationBadgeType.quizScore80 => Assets.imagesScore80,
      _ => Assets.imagesKeepLearning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StudyResultScreenScaffold(
      showCollectButton: true,
      onDone: () async {
        await GamificationBadgeCollector.collectQuizResult(
          correctCount: correctCount,
          totalCount: totalCount,
          sourceId: sourceId,
          attemptId: attemptId,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      illustration: Image.asset(
        _badgeAsset(),
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
          if (_showCongrats) ...[
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
          ],
          Text(
            l10n.quizYouHaveAnsweredPercent(percent),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
              height: 1.35,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.correctAnswers,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _showCongrats ? l10n.keepItUp : l10n.keepGoing,
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
