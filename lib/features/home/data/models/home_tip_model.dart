class HomeTipModel {
  const HomeTipModel({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;

  factory HomeTipModel.fromJson(Map<String, dynamic> json) {
    return HomeTipModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? json['content'] ?? json['title'] ?? '').toString(),
    );
  }
}
