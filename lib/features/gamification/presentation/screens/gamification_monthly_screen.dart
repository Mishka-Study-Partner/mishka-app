import 'package:flutter/material.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_ai_tools_monthly_screen.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_progress_monthly_screen.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_streak_calendar_screen.dart';
import 'package:mishka_app/features/gamification/utils/gamification_badge_assets.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum GamificationMonthlySection { streak, todo, aiTools, study, community }

/// Routes monthly drill-down screens from the gamification hub.
class GamificationMonthlyScreen extends StatelessWidget {
  const GamificationMonthlyScreen({
    super.key,
    required this.section,
  });

  final GamificationMonthlySection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (section) {
      GamificationMonthlySection.streak =>
        const GamificationStreakCalendarScreen(),
      GamificationMonthlySection.todo => GamificationProgressMonthlyScreen(
          section: GamificationMonthlySection.todo,
          appBarTitle: l10n.gamificationTodoMonthlyAppBar,
          pageTitle: l10n.gamificationTodoMonthlyTitle,
          pageTitleHighlight: l10n.gamificationMonthlyBadgesHighlight,
          goalSubtitle: l10n.gamificationTodoGoalWeekly,
          badgeAssetPath: Assets.imagesFinishingAllYourTasks,
          detailLineForWeek: (week) =>
              week.detailSubtitle ?? l10n.gamificationTasksPerWeek(30),
        ),
      GamificationMonthlySection.aiTools =>
        const GamificationAiToolsMonthlyScreen(),
      GamificationMonthlySection.study => GamificationProgressMonthlyScreen(
          section: GamificationMonthlySection.study,
          appBarTitle: l10n.gamificationStudyMonthlyAppBar,
          pageTitle: l10n.gamificationStudyMonthlyTitle,
          pageTitleHighlight: l10n.gamificationMonthlyBadgesHighlight,
          goalSubtitle: l10n.gamificationStudyGoalWeeklyShort,
          badgeAssetPath: GamificationBadgeAssets.sectionHeroAsset(
            GamificationSectionHero.study,
          ),
          detailLineForWeek: (_) => l10n.gamificationStudyHoursPerWeek(21),
        ),
      GamificationMonthlySection.community => GamificationProgressMonthlyScreen(
          section: GamificationMonthlySection.community,
          appBarTitle: l10n.gamificationCommunityMonthlyAppBar,
          pageTitle: l10n.gamificationCommunityMonthlyTitle,
          pageTitleHighlight: l10n.gamificationMonthlyBadgesHighlight,
          goalSubtitle: l10n.gamificationCommunityGoalWeekly,
          badgeAssetPath: GamificationBadgeAssets.sectionHeroAsset(
            GamificationSectionHero.community,
          ),
          detailLineForWeek: (_) =>
              l10n.gamificationCommunityPercentWeek(700),
        ),
    };
  }
}
