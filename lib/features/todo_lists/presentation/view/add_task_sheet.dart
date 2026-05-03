import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_text_field.dart';

import '../widgets/custom_mini_field.dart';
class AddTaskSheet extends StatelessWidget {
  const AddTaskSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width * 0.9;

    return Center(
      child: Container(
        width: width,
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  color: AppColors.mainGold,
                  size: AppSizes.iconSmall,
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.addNewTask,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "${l10n.task}",
              style: TextStyle(
                fontSize: AppSizes.fontSizeSmall,
                fontWeight: FontWeight.w500,
                fontFamily: "Pridi",
              ),
            ),
            SizedBox(height: 6.h),
            const ProfileTextField(
              value: "",
              label: '',
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.deadline,
              style: TextStyle(
                fontSize: AppSizes.fontSizeSmall,
                fontWeight: FontWeight.w500,
                fontFamily: "Pridi",
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(child: CustomMiniField(label: "Day")),
                SizedBox(width: 6.w),
                Expanded(child: CustomMiniField(label: "Month")),
                SizedBox(width: 6.w),
                Expanded(child: CustomMiniField(label: "Year")),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSmall,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                      ),
                      child: Text(
                        l10n.save,
                        style:  TextStyle(
                          color: AppColors.white,
                          fontFamily: "Pridi",
                          fontSize: 14.sp,height: 1.3
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeightSmall,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.red),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontFamily: "Pridi",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    ],
    ),
        ),
    );
  }
}
