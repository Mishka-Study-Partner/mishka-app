import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_text_field.dart';

class AddListSheet extends StatelessWidget {
  const AddListSheet({super.key});

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
                  l10n.addNewList,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  l10n.chooseListIcon,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeSmall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14.w),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.listName,
              style: TextStyle(
                fontFamily: "Pridi",
                fontSize: AppSizes.fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            const ProfileTextField(
              value: "",
              label: '',
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
                        style: const TextStyle(
                          color: AppColors.white,
                          height: 1.2,
                          fontFamily: "Pridi",
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

class TodoListIcon {
  final IconData icon;
  final Color color;

  const TodoListIcon(this.icon, this.color);
}
const availableIcons = [
  TodoListIcon(Icons.work, AppColors.mainGold),
  TodoListIcon(Icons.school, AppColors.blue),
  TodoListIcon(Icons.person, AppColors.green),
  TodoListIcon(Icons.favorite, AppColors.red),
  TodoListIcon(Icons.folder, AppColors.mainDark),
];
