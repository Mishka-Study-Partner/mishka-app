import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/todo_lists/data/repositories/todo_repository.dart';
import 'package:mishka_app/features/todo_lists/presentation/widgets/todo_list_icon_widget.dart';
import 'package:mishka_app/features/todo_lists/utils/todo_icon_catalog.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class AddListSheet extends StatefulWidget {
  const AddListSheet({super.key});

  @override
  State<AddListSheet> createState() => _AddListSheetState();
}

class _AddListSheetState extends State<AddListSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TodoRepository _repository = TodoRepository();

  List<TodoIconOption> _icons = List<TodoIconOption>.from(
    [TodoIconOption.defaultOption],
  );
  int _selectedIndex = 0;
  bool _loadingIcons = true;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    try {
      final apiIcons = await _repository.getIcons();
      if (!mounted) return;
      setState(() {
        _icons = TodoIconCatalog.merge(apiIcons);
        _selectedIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _icons = TodoIconCatalog.merge(const []);
      });
    } finally {
      if (mounted) {
        setState(() => _loadingIcons = false);
      }
    }
  }

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
            Text(
              l10n.chooseListIcon,
              style: TextStyle(
                fontFamily: "Pridi",
                fontSize: AppSizes.fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 56.h,
              child: _loadingIcons
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final selected = index == _selectedIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: selected
                                  ? icon.color.withValues(alpha: 0.15)
                                  : AppColors.lightFrameBackground,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: selected ? icon.color : AppColors.stroke,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: TodoListIconWidget(
                                option: icon,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                      onPressed: _loadingIcons
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                {
                                  'title': _titleController.text.trim(),
                                  'icon': _icons[_selectedIndex],
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
