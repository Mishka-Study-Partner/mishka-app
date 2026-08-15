import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/gamification/data/gamification_dashboard_model.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_monthly_screen.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_ai_tools_badges_section.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_hero_progress_section.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_section_header.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_streak_section.dart';
import 'package:mishka_app/features/gamification/utils/gamification_badge_assets.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/repositories/home_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/gamification_repository.dart';

class GamificationHubScreen extends StatefulWidget {
  const GamificationHubScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends State<GamificationHubScreen> {
  final GamificationRepository _repository = GamificationRepository();
  final HomeRepository _homeRepository = HomeRepository();

  GamificationDashboardModel? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final dashboard = await _repository.loadWeeklyDashboard();
    if (!mounted) return;
    setState(() {
      _dashboard = dashboard;
      _isLoading = false;
    });
  }

  Future<void> _openMonthly(GamificationMonthlySection section) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GamificationMonthlyScreen(section: section),
      ),
    );
    await _loadDashboard();
  }

  Future<void> _freezeMissedDay(DailyStreakDayModel day) async {
    if (!day.isMissed || day.date.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.streakFreezeTitle),
        content: Text(l10n.streakFreezeMessage(day.date)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.streakFreezeConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _homeRepository.freezeStreakDay(date: day.date);
      await _loadDashboard();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.streakFreezeFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = _dashboard ?? GamificationDashboardModel.empty();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.gamificationHubTitle,
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppScrollInsets.page(
                      horizontal: AppSizes.paddingMedium,
                      top: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GamificationStreakSection(
                          streakDays: data.streakDays,
                          streakWeek: data.streakWeek,
                          freezesRemaining: data.freezesRemaining,
                          onFreezeTap: _freezeMissedDay,
                          onMonthlyTap: () => _openMonthly(
                            GamificationMonthlySection.streak,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GamificationSectionHeader(
                              title: l10n.gamificationTodoSection,
                              weeklyLabel: l10n.gamificationWeekly,
                              monthlyLabel: l10n.gamificationMonthly,
                              onMonthlyTap: () => _openMonthly(
                                GamificationMonthlySection.todo,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GamificationHeroProgressSection(
                                section: GamificationSectionHero.tasks,
                                data: data.tasks,
                                goalText: l10n.gamificationTodoGoalWeekly,
                                primaryStat: l10n.gamificationTasksPerWeek(
                                  data.tasks.currentValue.round(),
                                ),
                                secondaryStat: l10n.gamificationTasksAwayFromBadge(
                                  data.tasks.remaining.round(),
                                ),
                                progressLabel: l10n.gamificationTasksProgress(
                                  data.tasks.currentValue.round(),
                                  data.tasks.goalValue.round(),
                                ),
                              monthlyBadgeText: l10n.gamificationBadgesEarnedMonth(
                                data.tasks.badgesEarnedThisMonth,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GamificationSectionHeader(
                              title: l10n.gamificationAiToolsSection,
                              weeklyLabel: l10n.gamificationWeekly,
                              monthlyLabel: l10n.gamificationMonthly,
                              onMonthlyTap: () => _openMonthly(
                                GamificationMonthlySection.aiTools,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GamificationAiToolsBadgesSection(
                              badges: data.aiToolBadges,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GamificationSectionHeader(
                              title: l10n.gamificationStudySection,
                              weeklyLabel: l10n.gamificationWeekly,
                              monthlyLabel: l10n.gamificationMonthly,
                              onMonthlyTap: () => _openMonthly(
                                GamificationMonthlySection.study,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GamificationHeroProgressSection(
                                section: GamificationSectionHero.study,
                                data: data.study,
                                goalText: l10n.gamificationStudyGoalWeekly,
                                primaryStat: l10n.gamificationStudyHoursPerWeek(
                                  data.study.currentValue.round(),
                                ),
                                secondaryStat: l10n.gamificationStudyHoursAway(
                                  data.study.remaining.round(),
                                ),
                                progressLabel: l10n.gamificationStudyProgress(
                                  data.study.currentValue.round(),
                                  data.study.goalValue.round(),
                                ),
                              monthlyBadgeText: l10n.gamificationBadgesEarnedMonth(
                                data.study.badgesEarnedThisMonth,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GamificationSectionHeader(
                              title: l10n.gamificationCommunitySection,
                              weeklyLabel: l10n.gamificationWeekly,
                              monthlyLabel: l10n.gamificationMonthly,
                              onMonthlyTap: () => _openMonthly(
                                GamificationMonthlySection.community,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GamificationHeroProgressSection(
                                section: GamificationSectionHero.community,
                                data: data.community,
                                goalText: l10n.gamificationCommunityGoalWeekly,
                                primaryStat: l10n.gamificationCommunityPercentWeek(
                                  data.community.currentValue.round(),
                                ),
                                secondaryStat:
                                    l10n.gamificationCommunityPercentAway(
                                  data.community.remaining.round(),
                                ),
                                progressLabel: l10n.gamificationCommunityProgress(
                                  data.community.currentValue.round(),
                                  data.community.goalValue.round(),
                                ),
                              monthlyBadgeText: l10n.gamificationBadgesEarnedMonth(
                                data.community.badgesEarnedThisMonth,
                              ),
                            ),
                          ],
                        ),
                        const ScreenEndSpacer(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
