class TodoListApiModel {
  const TodoListApiModel({
    required this.id,
    required this.title,
    this.sortOrder,
  });

  final String id;
  final String title;
  final int? sortOrder;

  factory TodoListApiModel.fromJson(Map<String, dynamic> json) {
    return TodoListApiModel(
      id: (json['id'] ?? '').toString(),
      title: (json['listName'] ?? json['title'] ?? json['name'] ?? '').toString(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );
  }
}
