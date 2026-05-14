import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/todo_lists/data/repositories/todo_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../ctegory/presentation/widgets/search_bar.dart';

import '../../data/models/list_item_model.dart';
import '../widgets/list_item.dart';
import '../widgets/to_do_button_action.dart';
import 'add_list_sheet.dart';
import 'add_task_sheet.dart';
import 'all_tasks_screen.dart';
import 'calender_Screen.dart';
import 'todo_list_details_screen.dart';
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TodoRepository _repository = TodoRepository();
  List<TodoListItemModel> lists = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);
    try {
      final remoteLists = await _repository.getTodoLists();
      if (!mounted) return;
      final mapped = remoteLists
          .map(
            (e) => TodoListItemModel(
              id: e.id,
              title: e.title,
              icon: Icons.list_alt,
              iconColor: AppColors.mainGold,
            ),
          )
          .toList();
      setState(() {
        lists = mapped;
      });
    } catch (_) {
      // Keep screen usable with static defaults when API fails.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _apiErrorMessage(Object error) {
    if (error is ApiException) {
      final buffer = StringBuffer();
      if (error.statusCode != null) {
        buffer.write('[${error.statusCode}] ');
      }
      if (error.error != null && error.error!.isNotEmpty) {
        buffer.write('[${error.error}] ');
      }
      buffer.write(error.message);
      if (error.details != null) {
        buffer.write('\n${error.details}');
      }
      return buffer.toString();
    }
    return error.toString();
  }

  Future<void> _openAddListSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddListSheet(),
    );

    if (result == null) return;

    final title = (result['title'] ?? '').toString().trim();
    if (title.isEmpty) return;
    try {
      await _repository.createTodoList(listName: title);
      await _loadLists();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  Future<void> _renameList(TodoListItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.title);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Container(
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
                Text(
                  l10n.renameList,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'Pridi'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      borderSide: const BorderSide(color: AppColors.stroke),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      borderSide: const BorderSide(color: AppColors.mainGold),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.stroke),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(fontFamily: 'Pridi', color: AppColors.mainDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pop(dialogContext, text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        child: Text(
                          l10n.save,
                          style: const TextStyle(fontFamily: 'Pridi', color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (newName == null || newName == item.title) return;

    try {
      await _repository.patchTodoList(id: item.id, listName: newName);
      await _loadLists();
    } catch (e) {
      if (!mounted) return;
      final l10n2 = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n2.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  Future<bool> _confirmDelete(TodoListItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
        child: Container(
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
              Text(
                l10n.toDoListTitle,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.deleteThisListQuestion,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.mainDark,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.stroke),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          color: AppColors.mainDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                      ),
                      child: Text(
                        l10n.delete,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  Future<void> _deleteListWithUndo({
    required int index,
    required TodoListItemModel item,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      lists = List<TodoListItemModel>.from(lists)..removeAt(index);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final result = await messenger
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            margin: EdgeInsets.all(AppSizes.paddingMedium),
            backgroundColor: Colors.transparent,
            duration: const Duration(seconds: 4),
            content: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline, color: AppColors.red),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${item.title} • ${l10n.listDeleted}',
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        color: AppColors.mainDark,
                        fontSize: AppSizes.fontSizeMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            action: SnackBarAction(
              label: l10n.undo,
              textColor: AppColors.mainGold,
              onPressed: () {},
            ),
          ),
        )
        .closed;

    if (result == SnackBarClosedReason.action) {
      if (!mounted) return;
      setState(() {
        final restored = List<TodoListItemModel>.from(lists);
        final restoreIndex = index.clamp(0, restored.length);
        restored.insert(restoreIndex, item);
        lists = restored;
      });
      return;
    }

    try {
      await _repository.deleteTodoList(id: item.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final restored = List<TodoListItemModel>.from(lists);
        final restoreIndex = index.clamp(0, restored.length);
        restored.insert(restoreIndex, item);
        lists = restored;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            MishkaSearchBar(hintText: l10n.searchList),
            SizedBox(height: 16.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: TodoListItem(
                            title: l10n.calendar,
                            icon: Icons.calendar_month,
                            iconColor: AppColors.mainGold,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TaskScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: TodoListItem(
                            title: l10n.allTasks,
                            icon: Icons.task_alt,
                            iconColor: AppColors.mainGold,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllTasksScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        ...List.generate(lists.length, (index) {
                          final item = lists[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirmDelete(item),
                              onDismissed: (_) => _deleteListWithUndo(
                                index: index,
                                item: item,
                              ),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                ),
                                child: const Icon(Icons.delete, color: AppColors.white),
                              ),
                              child: TodoListItem(
                                title: item.title,
                                icon: item.icon,
                                iconColor: item.iconColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TodoListDetailsScreen(
                                        listId: item.id,
                                        listName: item.title,
                                      ),
                                    ),
                                  );
                                },
                                onRename: () => _renameList(item),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            TodoBottomActions(
              onAddTask: () => _openAddTaskSheet(),
              onAddList: () => _openAddListSheet(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddTaskSheet() async {
    final l10n = AppLocalizations.of(context)!;

    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createListBeforeAddingTasks)),
      );
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddTaskSheet(lists: lists),
    );
    if (result == null) return;

    if (result['action'] == 'addList') {
      _openAddListSheet();
      return;
    }

    final title = (result['title'] ?? '').toString().trim();
    if (title.isEmpty) return;

    final listId = result['listId'] as String?;
    if (listId == null || listId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createListBeforeAddingTasks)),
      );
      return;
    }

    DateTime? deadline;
    final rawDate = result['deadline'];
    if (rawDate is DateTime) {
      deadline = rawDate;
    }

    if (!mounted) return;

    try {
      await _repository.createTask(
        title: title,
        deadline: deadline,
        todoListId: listId,
      );
      await _loadLists();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }
}

