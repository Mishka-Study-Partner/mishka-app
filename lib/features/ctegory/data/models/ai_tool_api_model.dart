class AiToolApiModel {
  const AiToolApiModel({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;

  factory AiToolApiModel.fromJson(Map<String, dynamic> json) {
    return AiToolApiModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['description'])?.toString(),
    );
  }
}
