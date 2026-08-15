import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishka_app/core/utils/app_colors.dart';

class GamificationMonthSelector extends StatelessWidget {
  const GamificationMonthSelector({
    super.key,
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> months;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected =
              month.year == selected.year && month.month == selected.month;
          final label = DateFormat('MMMM', locale).format(month);

          return GestureDetector(
            onTap: () => onSelected(month),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mainGold : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.mainGold),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.mainGold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
