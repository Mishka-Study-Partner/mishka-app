class TodoListApiModel {
  const TodoListApiModel({
    required this.id,
    required this.title,
    this.sortOrder,
    this.iconId,
    this.listType,
  });

  final String id;
  final String title;
  final int? sortOrder;
  final int? iconId;
  final String? listType;

  factory TodoListApiModel.fromJson(Map<String, dynamic> json) {
    final rawIconId = json['iconId'];
    int? iconId;
    if (rawIconId is int) {
      iconId = rawIconId;
    } else if (rawIconId != null) {
      iconId = int.tryParse(rawIconId.toString());
    }
    return TodoListApiModel(
      id: (json['id'] ?? '').toString(),
      title: (json['listName'] ?? json['title'] ?? json['name'] ?? '').toString(),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      iconId: iconId,
      listType: json['listType']?.toString(),
    );
  }
}
