import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/ctegory/presentation/widgets/search_bar.dart';
import 'package:mishka_app/features/todo_lists/data/models/list_item_model.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/repositories/todo_repository.dart';
import 'package:mishka_app/features/todo_lists/presentation/view/add_task_sheet.dart';
import 'package:mishka_app/features/todo_lists/presentation/widgets/custom_task_card.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class TodoListDetailsScreen extends StatefulWidget {
  const TodoListDetailsScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  final String listId;
  final String listName;

  @override
  State<TodoListDetailsScreen> createState() => _TodoListDetailsScreenState();
}

class _TodoListDetailsScreenState extends State<TodoListDetailsScreen> {
  final TodoRepository _repository = TodoRepository();
  bool _isLoading = true;
  List<TaskApiModel> _tasks = const [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
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

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _repository.getTasks(query: {'listId': widget.listId});
      if (!mounted) return;
      setState(() => _tasks = tasks);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddTaskSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddTaskSheet(
        lists: [
          TodoListItemModel(
            id: widget.listId,
            title: widget.listName,
            icon: Icons.list_alt,
            iconColor: AppColors.mainGold,
          ),
        ],
        preselectedListId: widget.listId,
      ),
    );
    if (result == null) return;

    final title = (result['title'] ?? '').toString().trim();
    if (title.isEmpty) return;

    DateTime? deadline;
    final rawDate = result['deadline'];
    if (rawDate is DateTime) {
      deadline = rawDate;
    }

    try {
      await _repository.createTask(
        title: title,
        deadline: deadline,
        todoListId: result['listId'] as String? ?? widget.listId,
      );
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  Future<void> _toggleTask(TaskApiModel task) async {
    final l10n = AppLocalizations.of(context)!;
    final wasCompleted = task.completed ?? false;
    final newStatus = wasCompleted ? 'pending' : 'completed';

    try {
      await _repository.patchTask(id: task.id, status: newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasCompleted ? l10n.taskMarkedPending : l10n.taskMarkedComplete,
          ),
        ),
      );
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  Future<void> _deleteTask(TaskApiModel task) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteTask(id: task.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.taskDeleted)),
      );
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  Future<void> _editTask(TaskApiModel task) async {
    final l10n = AppLocalizations.of(context)!;
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: task.title);
        return AlertDialog(
          title: Text(l10n.editTask),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.editTask),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (newTitle == null || newTitle.isEmpty || newTitle == task.title) return;

    try {
      await _repository.patchTask(id: task.id, title: newTitle);
      if (!mounted) return;
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  String _formatTaskDate(DateTime? deadline, String localeName) {
    if (deadline == null) return '--';
    return DateFormat.yMMMd(localeName).format(deadline.toLocal());
  }

  String _formatTaskTime(DateTime? deadline, String localeName) {
    if (deadline == null) return '--';
    return DateFormat.jm(localeName).format(deadline.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: widget.listName,
        topTitle: l10n.toDoListTitle,
        showBack: true,
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
                Expanded(
                  child: Text(
                    widget.listName,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeXXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MishkaSearchBar(hintText: l10n.searchList),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 32.h,
                    child: ElevatedButton(
                      onPressed: _openAddTaskSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: AppColors.white, size: 14.w),
                            SizedBox(width: 2.w),
                            Text(
                              l10n.addNewTask,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 11.sp,
                                fontFamily: 'Pridi',
                                height: 1.0,
                              ),
                              strutStyle: StrutStyle(
                                fontFamily: 'Pridi',
                                fontSize: 11.sp,
                                height: 1.4,
                                leading: 0,
                                forceStrutHeight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noUpcomingDeadlinesYet,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              fontSize: AppSizes.fontSizeMedium,
                              color: AppColors.greyText,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTasks,
                          child: ListView.separated(
                            itemCount: _tasks.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return CustomTaskCard(
                                title: task.title,
                                date: _formatTaskDate(task.deadline, localeName),
                                time: _formatTaskTime(task.deadline, localeName),
                                taskStatus: task.resolvedStatus,
                                onEdit: () => _editTask(task),
                                onDelete: () => _deleteTask(task),
                                onToggle: () => _toggleTask(task),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
