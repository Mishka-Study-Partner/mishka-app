import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/features/gamification/data/gamification_dashboard_model.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_section_card.dart';
import 'package:mishka_app/features/gamification/utils/gamification_badge_assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class GamificationAiToolsBadgesSection extends StatelessWidget {
  const GamificationAiToolsBadgesSection({
    super.key,
    required this.badges,
  });

  final List<GamificationAiToolBadgeStat> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GamificationSectionCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: badges.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _AiToolBadgeTile(
            imagePath: GamificationBadgeAssets.assetFor(badge.type),
            title: _titleFor(l10n, badge.type),
            footnote: badge.type == GamificationBadgeType.chatPoints
                ? l10n.gamificationChatBadgeFootnote
                : null,
            earnedText: l10n.gamificationBadgeEarnedCount(badge.timesEarned),
          );
        },
      ),
    );
  }

  String _titleFor(AppLocalizations l10n, GamificationBadgeType type) {
    return switch (type) {
      GamificationBadgeType.quizPerfect => l10n.gamificationBadgeQuizPerfect,
      GamificationBadgeType.quizScore80 => l10n.gamificationBadgeQuizScore80,
      GamificationBadgeType.quizKeepLearning =>
        l10n.gamificationBadgeQuizKeepLearning,
      GamificationBadgeType.flashcardsComplete =>
        l10n.gamificationBadgeFlashcards,
      GamificationBadgeType.summaryComplete => l10n.gamificationBadgeSummary,
      GamificationBadgeType.mindMapComplete => l10n.gamificationBadgeMindMap,
      GamificationBadgeType.chatPoints => l10n.gamificationBadgeChat,
    };
  }
}

class _AiToolBadgeTile extends StatelessWidget {
  const _AiToolBadgeTile({
    required this.imagePath,
    required this.title,
    required this.earnedText,
    this.footnote,
  });

  final String imagePath;
  final String title;
  final String earnedText;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Iconify(
              Mdi.medal,
              size: 40.sp,
              color: AppColors.mainGold,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
            height: 1.2,
          ),
        ),
        if (footnote != null) ...[
          SizedBox(height: 2.h),
          Text(
            footnote!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 8.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText,
            ),
          ),
        ],
        SizedBox(height: 2.h),
        Text(
          earnedText,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E9E5B),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
