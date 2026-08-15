import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/main_nav_destinations.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class MishkaBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MishkaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destinations = mainNavDestinations(l10n);

    return Container(
      height: 76.h,
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < destinations.length; i++)
            _navItem(
              context: context,
              index: i,
              label: destinations[i].label,
              icon: destinations[i].icon,
            ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required int index,
    required String label,
    required String icon,
  }) {
    final selected = index == currentIndex;
    final scheme = Theme.of(context).colorScheme;
    final inactive = scheme.onSurface.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            icon,
            color: selected ? AppColors.mainGold : inactive,
            size: 26.w,
          ),
          SizedBox(height: 4.h),
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.mainGold : inactive,
                ),
              ),
              if (selected)
                Container(
                  height: 2.h,
                  width: 28.w,
                  margin: EdgeInsets.only(top: 2.h),
                  color: AppColors.mainGold,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
