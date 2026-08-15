import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/gamification/data/data_sources/gamification_remote_data_source.dart';
import 'package:mishka_app/features/gamification/data/gamification_monthly_model.dart';
import 'package:mishka_app/features/gamification/data/gamification_repository.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_monthly_screen.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_month_selector.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_monthly_shared_widgets.dart';
import 'package:mishka_app/features/gamification/utils/gamification_monthly_utils.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class GamificationProgressMonthlyScreen extends StatefulWidget {
  const GamificationProgressMonthlyScreen({
    super.key,
    required this.section,
    required this.appBarTitle,
    required this.pageTitle,
    required this.pageTitleHighlight,
    required this.goalSubtitle,
    required this.badgeAssetPath,
    required this.detailLineForWeek,
  });

  final GamificationMonthlySection section;
  final String appBarTitle;
  final String pageTitle;
  final String pageTitleHighlight;
  final String goalSubtitle;
  final String badgeAssetPath;
  final String Function(GamificationMonthWeekStat week) detailLineForWeek;

  @override
  State<GamificationProgressMonthlyScreen> createState() =>
      _GamificationProgressMonthlyScreenState();
}

class _GamificationProgressMonthlyScreenState
    extends State<GamificationProgressMonthlyScreen> {
  final GamificationRepository _repository = GamificationRepository();

  late DateTime _selectedMonth;
  late List<DateTime> _monthTabs;
  bool _loading = true;
  GamificationProgressMonthlyData? _data;

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
    final data = await _repository.loadProgressMonthly(
      section: widget.section,
      month: _selectedMonth,
    );
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  List<GamificationMonthWeekStat> get _weeks => _data?.weeks ?? const [];

  String get _goalSubtitle {
    final fromApi = _data?.goalSubtitle ?? '';
    if (fromApi.isNotEmpty) return fromApi;
    return widget.goalSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final weeks = _weeks;

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
        title: widget.appBarTitle,
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
                            TextSpan(text: '${widget.pageTitle} '),
                            TextSpan(
                              text: widget.pageTitleHighlight,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _goalSubtitle,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mainGold,
                          height: 1.35,
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
                      SizedBox(height: 16.h),
                      if (weeks.isNotEmpty) ...[
                        GamificationMonthlySummaryCard(
                          badgeAssetPath: widget.badgeAssetPath,
                          weeks: weeks,
                          weekLabelBuilder: weekLabel,
                          rangeLabelBuilder: rangeLabel,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.gamificationDetailsLabel,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeMedium,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainDark,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        for (final week in weeks)
                          GamificationMonthlyWeekDetailCard(
                            title: '${weekLabel(week)} [${rangeLabel(week)}]',
                            subtitle: week.detailSubtitle ??
                                widget.detailLineForWeek(week),
                            progress: week.progress,
                            progressLabel: week.progressLabel,
                            goalMet: week.goalMet,
                          ),
                      ],
                      const ScreenEndSpacer(),
                    ],
                  ),
                ),
    );
  }
}
