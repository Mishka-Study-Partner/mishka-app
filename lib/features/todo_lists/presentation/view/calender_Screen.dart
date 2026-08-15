import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/repositories/todo_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../widgets/calender.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TodoRepository _repository = TodoRepository();
  List<DateTime> _taskDates = const [];
  List<TaskApiModel> _selectedDayTasks = const [];
  DateTime? _selectedDate;
  bool _isLoading = true;
  List<TaskApiModel> _allTasks = const [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('📅 CalendarScreen: fetching tasks per-list…');
      final lists = await _repository.getTodoLists();
      final all = <TaskApiModel>[];
      for (final list in lists) {
        final tasks = await _repository.getTasks(query: {'listId': list.id});
        all.addAll(tasks);
      }
      debugPrint('📅 CalendarScreen: got ${all.length} tasks from ${lists.length} lists');
      if (!mounted) return;
      final dates = all
          .where((t) => t.deadline != null)
          .map((t) => DateTime(
                t.deadline!.year,
                t.deadline!.month,
                t.deadline!.day,
              ))
          .toSet()
          .toList();
      setState(() {
        _allTasks = all;
        _taskDates = dates;
      });
    } catch (e) {
      debugPrint('📅 CalendarScreen: _loadTasks error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDaySelected(DateTime date) {
    final dayTasks = _allTasks.where((t) {
      if (t.deadline == null) return false;
      final d = t.deadline!;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
    setState(() {
      _selectedDate = date;
      _selectedDayTasks = dayTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.myTasks,
        topTitle: l10n.toDoListTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  CustomCalendar(
                    taskDates: _taskDates,
                    onDaySelected: _onDaySelected,
                  ),
                  SizedBox(height: 16.h),
                  if (_selectedDate != null && _selectedDayTasks.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Text(
                        l10n.noUpcomingDeadlinesYet,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          color: AppColors.greyText,
                        ),
                      ),
                    ),
                  if (_selectedDayTasks.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                            padding: AppScrollInsets.list(),
                        itemCount: _selectedDayTasks.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final task = _selectedDayTasks[index];
                          final isCompleted = task.completed ?? false;
                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              border: Border.all(color: AppColors.stroke),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppColors.mainGold.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: isCompleted
                                          ? AppColors.mainGold
                                          : AppColors.greyText,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? Icon(Icons.check, size: 14.w, color: AppColors.mainGold)
                                      : null,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontFamily: 'Pridi',
                                      fontSize: AppSizes.fontSizeMedium,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.mainDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
