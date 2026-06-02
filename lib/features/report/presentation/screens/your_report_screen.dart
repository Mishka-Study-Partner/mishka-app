import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/custom_segmanted_button.dart';
import 'package:mishka_app/features/home/presentation/widgets/daily_streak_week_row.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/repositories/report_repository.dart';
import 'package:mishka_app/features/report/presentation/services/report_pdf_service.dart';
import 'package:mishka_app/features/report/utils/report_recipient_email.dart';
import 'package:mishka_app/features/report/presentation/widgets/report_chart_widgets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class YourReportScreen extends StatefulWidget {
  const YourReportScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<YourReportScreen> createState() => _YourReportScreenState();
}

class _YourReportScreenState extends State<YourReportScreen> {
  final ReportRepository _repository = ReportRepository();
  final ReportPdfService _pdfService = ReportPdfService();

  ReportPeriod _period = ReportPeriod.weekly;
  YourReportSnapshot? _snapshot;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload can leave stale snapshot shapes; refetch after model changes.
    _snapshot = null;
    _load(forceRefresh: true);
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final cached = _snapshot;
    if (cached == null) {
      setState(() => _loading = true);
    }
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final snapshot = await _repository.loadReport(
        _period,
        forceRefresh: forceRefresh,
        locale: locale,
      );
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _exportPdf() async {
    final snapshot = _snapshot;
    if (snapshot == null || !snapshot.canExportPdf || _exporting) return;

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _exporting = true);
    try {
      final recipient = ReportRecipientEmail.resolve();
      final outcome = await _pdfService.exportReport(
        period: _period,
        anchorDate: DateTime.now(),
        locale: locale,
        snapshot: snapshot,
        delivery: 'both',
        emailTo: recipient.email,
        useCustomRecipient: recipient.useCustomRecipient,
        title: l10n.yourReport,
        studySectionTitle: _studyTitle(l10n),
        aiSectionTitle: _aiTitle(l10n),
        streakSectionTitle: _streakTitle(l10n),
        tasksSectionTitle: _tasksTitle(l10n),
        streakCurrentLabel: l10n.reportStreakCurrent,
        streakLongestLabel: l10n.reportStreakLongest,
        streakFreezesLabel: l10n.reportStreakFreezes,
        quizzesLabel: l10n.reportTotalQuizzes,
        flashcardsLabel: l10n.reportTotalFlashcards,
        summariesLabel: l10n.reportTotalSummaries,
      );
      if (!mounted) return;

      switch (outcome.mode) {
        case ReportExportMode.server:
          final result = outcome.result!;
          if (result.emailedTo != null && result.emailedTo!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.reportPdfEmailSent(result.emailedTo!))),
            );
          }
          if (result.pdfUrl != null) {
            final opened = await _pdfService.openPdfUrl(result.pdfUrl);
            if (!opened && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.reportPdfOpenFailed)),
              );
            }
          }
        case ReportExportMode.localFallback:
          final file = outcome.localFile!;
          await _pdfService.shareLocalFile(
            file,
            subject: '${l10n.yourReport} — ${snapshot.periodLabel}',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.reportPdfSharedLocally)),
            );
          }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportPdfFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _periodSuffix(AppLocalizations l10n) {
    return switch (_period) {
      ReportPeriod.daily => l10n.reportPeriodDailySuffix,
      ReportPeriod.weekly => l10n.reportPeriodWeeklySuffix,
      ReportPeriod.monthly => l10n.reportPeriodMonthlySuffix,
      ReportPeriod.yearly => l10n.reportPeriodYearlySuffix,
    };
  }

  String _studyTitle(AppLocalizations l10n) =>
      '${l10n.reportStudyWithMishka} (${_periodSuffix(l10n)})';
  String _aiTitle(AppLocalizations l10n) =>
      '${l10n.reportAiTools} (${_periodSuffix(l10n)})';
  String _streakTitle(AppLocalizations l10n) =>
      '${l10n.reportDailyStreak} (${_periodSuffix(l10n)})';
  String _tasksTitle(AppLocalizations l10n) =>
      '${l10n.reportTasksDue} (${_periodSuffix(l10n)})';

  String _communityTitle(AppLocalizations l10n) =>
      '${l10n.reportCommunitySection} (${_periodSuffix(l10n)})';

  List<String> _periodSegments(AppLocalizations l10n) => [
        l10n.reportPeriodDaily,
        l10n.reportPeriodWeekly,
        l10n.reportPeriodMonthly,
        l10n.reportPeriodYearly,
      ];

  ReportPeriod _periodFromIndex(int index) => switch (index) {
        0 => ReportPeriod.daily,
        1 => ReportPeriod.weekly,
        2 => ReportPeriod.monthly,
        _ => ReportPeriod.yearly,
      };

  int _indexFromPeriod(ReportPeriod period) => switch (period) {
        ReportPeriod.daily => 0,
        ReportPeriod.weekly => 1,
        ReportPeriod.monthly => 2,
        ReportPeriod.yearly => 3,
      };

  Widget _buildTasksCompletedChart(List<ReportBucket> buckets) {
    final chart = ReportHorizontalBars(
      buckets: buckets,
      valueAsPercent: false,
    );
    if (buckets.length <= 7) return chart;
    return SizedBox(
      height: 280.h,
      child: SingleChildScrollView(child: chart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.yourReport,
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),
      body: _loading && _snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(forceRefresh: true),
              child: Stack(
                children: [
                  _buildContent(l10n),
                  if (_loading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final snapshot = _snapshot;
    return ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.paddingMedium,
                  12.h,
                  AppSizes.paddingMedium,
                  24.h,
                ),
                children: [
                  CustomSegmentedButton(
                    selectedIndex: _indexFromPeriod(_period),
                    segments: _periodSegments(l10n),
                    onChanged: (index) {
                      setState(() => _period = _periodFromIndex(index));
                      _load();
                    },
                  ),
                  SizedBox(height: 14.h),
                  if (snapshot != null)
                    Text(
                      snapshot.periodLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeMedium,
                        color: AppColors.lightText,
                      ),
                    ),
                  if (snapshot?.dataSource == ReportDataSource.legacy) ...[
                    SizedBox(height: 8.h),
                    Text(
                      l10n.reportUsingLegacyData,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeSmall,
                        color: AppColors.mainGold,
                      ),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  if (snapshot?.canExportPdf ?? false)
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : _exportPdf,
                        icon: _exporting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.mail_outline),
                        label: Text(l10n.reportEmailMyReport),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGold,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                      ),
                    ),
                  if (snapshot?.canExportPdf ?? false) SizedBox(height: 16.h),
                  if (snapshot != null) ...[
                    ReportSectionCard(
                      title: _streakTitle(l10n),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.hasStreakWeek) ...[
                            DailyStreakWeekRow(week: snapshot.streakWeek),
                            SizedBox(height: 16.h),
                          ],
                          ReportStreakSummary(
                            current: snapshot.currentStreak,
                            longest: snapshot.longestStreak,
                            freezes: snapshot.freezesRemaining,
                            currentLabel: l10n.reportStreakCurrent,
                            longestLabel: l10n.reportStreakLongest,
                            freezesLabel: l10n.reportStreakFreezes,
                          ),
                        ],
                      ),
                    ),
                    ReportSectionCard(
                      title: _studyTitle(l10n),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reportDuringConcentrationMode,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: AppSizes.fontSizeMedium,
                              color: AppColors.mainDark,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ReportVerticalBarChart(
                            buckets: snapshot.studyMinutes,
                          ),
                        ],
                      ),
                    ),
                    ReportSectionCard(
                      title: _aiTitle(l10n),
                      child: Row(
                        children: [
                          ReportProgressRing(
                            percent: snapshot.aiTools.percentFor(
                              snapshot.aiTools.quizzes,
                              _period,
                            ),
                            label: l10n.reportTotalQuizzes,
                          ),
                          ReportProgressRing(
                            percent: snapshot.aiTools.percentFor(
                              snapshot.aiTools.flashcards,
                              _period,
                            ),
                            label: l10n.reportTotalFlashcards,
                          ),
                          ReportProgressRing(
                            percent: snapshot.aiTools.percentFor(
                              snapshot.aiTools.summaries,
                              _period,
                            ),
                            label: l10n.reportTotalSummaries,
                          ),
                        ],
                      ),
                    ),
                    if (snapshot.community.hasActivity)
                      ReportSectionCard(
                        title: _communityTitle(l10n),
                        child: ReportCommunitySummary(
                          stats: snapshot.community,
                          messagesLabel: l10n.reportCommunityMessages,
                          sharesLabel: l10n.reportCommunityMaterialShares,
                          joinsLabel: l10n.reportCommunityChannelJoins,
                        ),
                      ),
                    ReportSectionCard(
                      title: _tasksTitle(l10n),
                      child: snapshot.tasksCompletedByDay.isNotEmpty
                          ? _buildTasksCompletedChart(
                              snapshot.tasksCompletedByDay,
                            )
                          : ReportEmptyHint(
                              message: l10n.reportNoTasksInPeriod,
                            ),
                    ),
                  ] else
                    Padding(
                      padding: EdgeInsets.only(top: 48.h),
                      child: Text(
                        l10n.reportLoadFailed,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          color: AppColors.lightText,
                        ),
                      ),
                    ),
                ],
    );
  }
}
