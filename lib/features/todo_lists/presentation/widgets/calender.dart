import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum MonthDirection { next, previous }

class CustomCalendar extends StatefulWidget {
  final List<DateTime> taskDates;
  final void Function(DateTime)? onDaySelected;

  const CustomCalendar({
    super.key,
    required this.taskDates,
    this.onDaySelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime currentMonth;
  DateTime? selectedDay;
  MonthDirection direction = MonthDirection.next;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mainGold),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 16.h),
          _buildWeekDays(),
          SizedBox(height: 12.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              final beginOffset = direction == MonthDirection.next
                  ? const Offset(1, 0)
                  : const Offset(-1, 0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: beginOffset,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: _buildDaysGrid(
              key: ValueKey(currentMonth.month),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, size: AppSizes.iconSmall),
          onPressed: () {
            setState(() {
              direction = MonthDirection.previous;
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month - 1);
            });
          },
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppScale.w(16),
            vertical: AppScale.h(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.mainGold,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            DateFormat('MMMM / yyyy').format(currentMonth),
            style: TextStyle(
              color: AppColors.white,
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: AppSizes.iconSmall),
          onPressed: () {
            setState(() {
              direction = MonthDirection.next;
              currentMonth =
                  DateTime(currentMonth.year, currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];

    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid({required Key key}) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday - 1;
    final totalCells = startWeekday + daysInMonth;

    return GridView.builder(
      key: key,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppScale.h(8),
        crossAxisSpacing: AppScale.w(8),
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox();
        }

        final dayNumber = index - startWeekday + 1;
        final date = DateTime(
          currentMonth.year,
          currentMonth.month,
          dayNumber,
        );

        final hasTask = widget.taskDates.any(
          (d) =>
              d.year == date.year &&
              d.month == date.month &&
              d.day == date.day,
        );

        final isSelected = selectedDay != null &&
            selectedDay!.day == date.day &&
            selectedDay!.month == date.month &&
            selectedDay!.year == date.year;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = date;
            });
            widget.onDaySelected?.call(date);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.mainGold
                  : hasTask
                      ? AppColors.mainGold.withValues(alpha: 0.25)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.white
                      : hasTask
                          ? AppColors.mainGold
                          : AppColors.mainDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
