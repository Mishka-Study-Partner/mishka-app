import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class AddListSheet extends StatefulWidget {
  const AddListSheet({super.key});

  @override
  State<AddListSheet> createState() => _AddListSheetState();
}

class _AddListSheetState extends State<AddListSheet> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: l10n.listName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          {
                            'title': _titleController.text.trim(),
                            'icon': availableIcons.first,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        l10n.save,
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Pridi',
                          fontSize: 13.sp,
                          height: 1.0,
                        ),
                        strutStyle: StrutStyle(
                          fontFamily: 'Pridi',
                          fontSize: 13.sp,
                          height: 1.4,
                          leading: 0,
                          forceStrutHeight: true,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: AppColors.red,
                          fontFamily: 'Pridi',
                          fontSize: 13.sp,
                          height: 1.0,
                        ),
                        strutStyle: StrutStyle(
                          fontFamily: 'Pridi',
                          fontSize: 13.sp,
                          height: 1.4,
                          leading: 0,
                          forceStrutHeight: true,
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
