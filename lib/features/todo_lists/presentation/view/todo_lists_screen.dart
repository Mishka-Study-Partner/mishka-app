import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../ctegory/presentation/widgets/search_bar.dart';

import '../../data/models/list_item_model.dart';
import '../widgets/list_item.dart';
import '../widgets/to_do_button_action.dart';
import 'add_list_sheet.dart';
import 'add_task_sheet.dart';
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late List<TodoListItemModel> lists;
  Future<void> _openAddListSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddListSheet(),
    );

    if (result == null) return;

    setState(() {
      lists.add(
        TodoListItemModel(
          title: result["title"],
          icon: result["icon"].icon,
          iconColor: result["icon"].color,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    lists = [
      TodoListItemModel(
        title: l10n.calender,
        icon: Icons.calendar_today,
        iconColor: AppColors.mainGold,
      ),
      TodoListItemModel(
        title: l10n.allTasks,
        icon: Icons.list_alt,
        iconColor: AppColors.blue,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.toDoListTitle,
        topTitle: l10n.toDoListTitle,
        showBack: false,
        showBottomBar: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: AppColors.mainGold,
                  size: AppSizes.iconSmall,
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.yourList,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeXXLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  Assets.imagesToDoList,
                  height: 40.h,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            MishkaSearchBar(
              hintText: l10n.searchList,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final item = lists[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: TodoListItem(
                      title: item.title,
                      icon: item.icon,
                      iconColor: item.iconColor,
                    ),
                  );
                },
              ),
            ),
            TodoBottomActions(
              onAddTask: () => _showAddTaskSheet(context),
              onAddList: () => _openAddListSheet(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _showAddListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddListSheet(),
    );
  }
}

