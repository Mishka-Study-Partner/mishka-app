import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/todo_lists/data/data_sources/todo_remote_data_source.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/models/todo_list_api_model.dart';

class TodoRepository {
  TodoRepository({TodoRemoteDataSource? remote})
      : _remote = remote ?? TodoRemoteDataSource(ApiService());

  final TodoRemoteDataSource _remote;

  Future<List<TodoListApiModel>> getTodoLists() => _remote.getTodoLists();

  Future<TodoListApiModel> createTodoList({
    required String listName,
    String listType = 'personal',
    int? iconId,
  }) =>
      _remote.createTodoList(listName: listName, listType: listType, iconId: iconId);

  Future<void> deleteTodoList({required String id}) =>
      _remote.deleteTodoList(id: id);

  Future<void> patchTodoList({
    required String id,
    String? listName,
    String? listType,
    int? iconId,
  }) =>
      _remote.patchTodoList(id: id, listName: listName, listType: listType, iconId: iconId);

  Future<List<TaskApiModel>> getTasks({Map<String, dynamic>? query}) =>
      _remote.getTasks(query: query);

  Future<TaskApiModel> createTask({
    required String title,
    DateTime? deadline,
    String? todoListId,
  }) =>
      _remote.createTask(title: title, deadline: deadline, todoListId: todoListId);

  Future<TaskApiModel> patchTask({
    required String id,
    String? title,
    DateTime? dueDate,
    String? status,
    String? priority,
  }) =>
      _remote.patchTask(
        id: id,
        title: title,
        dueDate: dueDate,
        status: status,
        priority: priority,
      );

  Future<void> deleteTask({required String id}) =>
      _remote.deleteTask(id: id);
}
