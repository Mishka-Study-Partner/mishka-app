import 'package:mishka_app/features/todo_lists/utils/todo_icon_catalog.dart';

class TodoListItemModel {
  final String id;
  final String title;
  final TodoIconOption icon;

  TodoListItemModel({
    required this.id,
    required this.title,
    required this.icon,
  });
}
