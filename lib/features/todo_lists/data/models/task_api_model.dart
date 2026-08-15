import 'package:mishka_app/features/todo_lists/data/task_due_fields.dart';

enum TaskStatus { completed, pending, missed }

class TaskApiModel {
  const TaskApiModel({
    required this.id,
    required this.title,
    this.todoListId,
    this.todoListTitle,
    this.deadline,
    this.hasDueTime = false,
    this.completed,
    this.status,
    this.completedAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? todoListId;
  final String? todoListTitle;
  final DateTime? deadline;
  final bool hasDueTime;
  final bool? completed;
  final String? status;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  /// Resolves the visual state of the task based on status + deadline.
  TaskStatus get resolvedStatus {
    if (completed == true || status == 'completed') return TaskStatus.completed;
    if (deadline != null && deadline!.isBefore(DateTime.now())) {
      return TaskStatus.missed;
    }
    return TaskStatus.pending;
  }

  factory TaskApiModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed == null) return null;
      return parsed.toLocal();
    }

    final dueTimeRaw = json['dueTime'];
    final deadline = TaskDueFields.decode(
      dueDate: json['deadline'] ??
          json['dueDate'] ??
          json['dueAt'] ??
          json['date'],
      dueTime: dueTimeRaw,
    );

    final list = json['todoList'];
    String? listTitle;
    if (list is Map<String, dynamic>) {
      listTitle = list['title']?.toString();
    }

    final statusRaw = json['status']?.toString();
    final isCompleted = json['isCompleted'] as bool? ??
        json['completed'] as bool? ??
        (statusRaw == 'completed');

    return TaskApiModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['task'] ?? '').toString(),
      todoListId: json['listId']?.toString() ?? json['todoListId']?.toString(),
      todoListTitle: listTitle ?? json['todoListTitle']?.toString(),
      deadline: deadline,
      hasDueTime: TaskDueFields.hasDueTime(
        dueTime: dueTimeRaw,
        dueDate: json['dueDate'] ?? json['deadline'] ?? json['dueAt'] ?? json['date'],
      ),
      completed: isCompleted,
      status: statusRaw,
      completedAt: parseDate(
        json['completedAt'] ??
            json['completed_at'] ??
            json['finishedAt'] ??
            json['finished_at'],
      ),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }
}
