import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/models/todo_list_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/task_due_fields.dart';

class TodoRemoteDataSource {
  TodoRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<TodoListApiModel>> getTodoLists() async {
    final env = await _api.get<List<TodoListApiModel>>(
      ApiEndpoints.todoLists,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => TodoListApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  /// [listType] must match API: `calendar` | `college` | `work` | `personal`.
  Future<TodoListApiModel> createTodoList({
    required String listName,
    String listType = 'personal',
    int? iconId,
  }) async {
    final env = await _api.post<TodoListApiModel>(
      ApiEndpoints.todoLists,
      data: {
        'listName': listName,
        'listType': listType,
        if (iconId != null) 'iconId': iconId,
      },
      dataFromJson: (raw) {
        if (raw is List && raw.isNotEmpty && raw.first is Map) {
          return TodoListApiModel.fromJson(
            Map<String, dynamic>.from(raw.first as Map),
          );
        }
        if (raw is Map) {
          return TodoListApiModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid todo list response');
      },
    );
    final data = env.data;
    if (data == null) {
      throw const FormatException('Empty todo list response');
    }
    return data;
  }

  Future<void> deleteTodoList({required String id}) async {
    await _api.delete<void>(
      ApiEndpoints.todoListById(id),
    );
  }

  Future<List<TaskApiModel>> getTasks({Map<String, dynamic>? query}) async {
    final env = await _api.get<List<TaskApiModel>>(
      ApiEndpoints.tasks,
      queryParameters: query,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => TaskApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }


  Future<void> patchTodoList({
    required String id,
    String? listName,
    String? listType,
    int? iconId,
  }) async {
    await _api.patch<void>(
      ApiEndpoints.todoListById(id),
      data: {
        if (listName != null) 'listName': listName,
        if (listType != null) 'listType': listType,
        if (iconId != null) 'iconId': iconId,
      },
    );
  }

  /// `PATCH /tasks/{id}` — update title, dueDate, status, etc.
  Future<TaskApiModel> patchTask({
    required String id,
    String? title,
    DateTime? dueDate,
    String? status,
    String? priority,
  }) async {
    final env = await _api.patch<TaskApiModel>(
      ApiEndpoints.taskById(id),
      data: {
        if (title != null) 'title': title,
        if (dueDate != null) ...TaskDueFields.encode(dueDate),
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
      },
      dataFromJson: (raw) {
        if (raw is Map) {
          return TaskApiModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid task response');
      },
    );
    final data = env.data;
    if (data == null) throw const FormatException('Empty task response');
    return data;
  }

  /// `DELETE /tasks/{id}` — delete a task.
  Future<void> deleteTask({required String id}) async {
    await _api.delete<void>(ApiEndpoints.taskById(id));
  }

  Future<TaskApiModel> createTask({
    required String title,
    DateTime? deadline,
    String? todoListId,
  }) async {
    final env = await _api.post<TaskApiModel>(
      ApiEndpoints.tasks,
      data: {
        'title': title,
        if (todoListId != null && todoListId.isNotEmpty) 'listId': todoListId,
        if (deadline != null) ...TaskDueFields.encode(deadline),
      },
      dataFromJson: (raw) {
        if (raw is List && raw.isNotEmpty && raw.first is Map) {
          return TaskApiModel.fromJson(Map<String, dynamic>.from(raw.first as Map));
        }
        if (raw is Map) {
          return TaskApiModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid task response');
      },
    );
    final data = env.data;
    if (data == null) {
      throw const FormatException('Empty task response');
    }
    return data;
  }
}
