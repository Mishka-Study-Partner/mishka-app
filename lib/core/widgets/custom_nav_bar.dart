import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/lucide.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
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
    
    return Container(
      height: 72.h,
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context: context,
            index: 0,
            label: l10n.home,
            icon: Mdi.home_outline,
          ),
          _navItem(
            context: context,
            index: 1,
            label: l10n.toDo,
            icon: Lucide.layout_list,
          ),
          _navItem(
            context: context,
            index: 2,
            label: l10n.category,
            icon: Mdi.category_outline,
          ),
          _navItem(
            context: context,
            index: 3,
            label: l10n.saved,
            icon: Mdi.content_save_check,
          ),
          _navItem(
            context: context,
            index: 4,
            label: l10n.profile,
            icon: Mdi.account_circle_outline,
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
    bool selected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            icon,
            color: selected ? AppColors.mainGold : AppColors.mainDark,
            size: 26.w,
          ),
          SizedBox(height: 4.h),
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.mainGold : AppColors.mainDark,
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
