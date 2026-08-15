import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/gamification/data/data_sources/gamification_remote_data_source.dart';
import 'package:mishka_app/features/gamification/data/gamification_monthly_model.dart';
import 'package:mishka_app/features/gamification/data/gamification_repository.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_month_selector.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_monthly_shared_widgets.dart';
import 'package:mishka_app/features/gamification/utils/gamification_monthly_utils.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class GamificationAiToolsMonthlyScreen extends StatefulWidget {
  const GamificationAiToolsMonthlyScreen({super.key});

  @override
  State<GamificationAiToolsMonthlyScreen> createState() =>
      _GamificationAiToolsMonthlyScreenState();
}

class _GamificationAiToolsMonthlyScreenState
    extends State<GamificationAiToolsMonthlyScreen> {
  final GamificationRepository _repository = GamificationRepository();

  late DateTime _selectedMonth;
  late List<DateTime> _monthTabs;
  bool _loading = true;
  GamificationAiToolsMonthlyData? _data;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _monthTabs = GamificationMonthlyUtils.monthTabs(anchor: _selectedMonth);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final data = await _repository.loadAiToolsMonthly(_selectedMonth);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  List<GamificationMonthlyBadgeGroup> get _groups => _data?.groups ?? const [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final groups = _groups;

    String weekLabel(GamificationMonthWeekStat week) =>
        l10n.gamificationWeekLabel(week.weekIndex);
    String rangeLabel(GamificationMonthWeekStat week) =>
        GamificationMonthlyUtils.formatWeekRange(
          week.rangeStart,
          week.rangeEnd,
          locale,
        );

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.gamificationAiToolsMonthlyAppBar,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
                  padding: AppScrollInsets.page(
                    horizontal: AppSizes.paddingMedium,
                    top: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeLarge,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mainDark,
                          ),
                          children: [
                            TextSpan(
                              text: '${l10n.gamificationAiToolsMonthlyTitle} ',
                            ),
                            TextSpan(
                              text: l10n.gamificationMonthlyBadgesHighlight,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      GamificationMonthSelector(
                        months: _monthTabs,
                        selected: _selectedMonth,
                        onSelected: (month) {
                          setState(() => _selectedMonth = month);
                          _loadMonth();
                        },
                      ),
                      SizedBox(height: 20.h),
                      if (groups.isNotEmpty)
                        for (final group in groups) ...[
                          Text(
                            group.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainDark,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          GamificationMonthlySummaryCard(
                            badgeAssetPath: group.badgeAssetPath,
                            weeks: group.weeks,
                            weekLabelBuilder: weekLabel,
                            rangeLabelBuilder: rangeLabel,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            l10n.gamificationDetailsLabel,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainDark,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 110.h,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (final week in group.weeks)
                                  GamificationMonthlyAiWeekDetailCard(
                                    week: week,
                                    weekLabel: weekLabel(week),
                                    rangeLabel: rangeLabel(week),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      const ScreenEndSpacer(),
                    ],
                  ),
                ),
    );
  }
}
