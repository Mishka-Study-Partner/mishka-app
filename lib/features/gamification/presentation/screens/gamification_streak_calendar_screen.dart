import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/gamification/data/data_sources/gamification_remote_data_source.dart';
import 'package:mishka_app/features/gamification/data/gamification_monthly_model.dart';
import 'package:mishka_app/features/gamification/data/gamification_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class GamificationStreakCalendarScreen extends StatefulWidget {
  const GamificationStreakCalendarScreen({super.key});

  @override
  State<GamificationStreakCalendarScreen> createState() =>
      _GamificationStreakCalendarScreenState();
}

class _GamificationStreakCalendarScreenState
    extends State<GamificationStreakCalendarScreen> {
  final GamificationRepository _repository = GamificationRepository();

  late DateTime _month;
  bool _loading = true;
  GamificationStreakMonthlyData? _data;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final data = await _repository.loadStreakMonthly(_month);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _shiftMonth(int delta) async {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    await _loadMonth();
  }

  List<GamificationStreakCalendarDay> get _days => _data?.days ?? const [];

  int get _streakCount => _data?.streakDaysInMonth ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final days = _days;
    final monthLabel = DateFormat('MMMM', locale).format(_month);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.gamificationStreakCalendarTitle,
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
                      Row(
                        children: [
                          Iconify(
                            Mdi.fire,
                            size: 16.sp,
                            color: const Color(0xFF2E9E5B),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10n.gamificationStreakDaysPerMonth(_streakCount),
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E9E5B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => _shiftMonth(-1),
                                  icon: Icon(
                                    Icons.chevron_left,
                                    color: AppColors.mainGold,
                                    size: 24.sp,
                                  ),
                                ),
                                Text(
                                  monthLabel,
                                  style: TextStyle(
                                    fontFamily: 'Pridi',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mainGold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _shiftMonth(1),
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color: AppColors.mainGold,
                                    size: 24.sp,
                                  ),
                                ),
                              ],
                            ),
                            if (days.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              _WeekdayHeader(l10n: l10n),
                              SizedBox(height: 8.h),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 6.h,
                                  crossAxisSpacing: 4.w,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  return _StreakDayCell(day: days[index]);
                                },
                              ),
                              SizedBox(height: 12.h),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16.w,
                                runSpacing: 8.h,
                                children: [
                                  _LegendDot(
                                    color: AppColors.mainGold,
                                    label: l10n.gamificationStreakOpenedApp,
                                  ),
                                  _LegendDot(
                                    color: const Color(0xFFE04B4B),
                                    label: l10n.gamificationStreakMissedApp,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const ScreenEndSpacer(),
                    ],
                  ),
                ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final labels = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.mainDark,
              ),
            ),
          ),
      ],
    );
  }
}

class _StreakDayCell extends StatelessWidget {
  const _StreakDayCell({required this.day});

  final GamificationStreakCalendarDay day;

  @override
  Widget build(BuildContext context) {
    final dayNum = day.date.day.toString();
    final status = day.status;

    if (status == GamificationStreakDayStatus.outsideMonth) {
      return Center(
        child: Text(
          dayNum,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 12.sp,
            color: AppColors.lightText.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final bg = status == GamificationStreakDayStatus.opened
        ? AppColors.mainGold
        : const Color(0xFFE04B4B);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        dayNum,
        style: TextStyle(
          fontFamily: 'Pridi',
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 10.sp,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
