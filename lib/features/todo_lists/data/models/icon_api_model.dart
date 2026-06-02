class IconApiModel {
  const IconApiModel({
    required this.id,
    required this.iconName,
    this.iconPath,
  });

  final int id;
  final String iconName;
  final String? iconPath;

  factory IconApiModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return IconApiModel(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      iconName: (json['iconName'] ?? json['name'] ?? '').toString(),
      iconPath: (json['iconPath'] ?? json['path'])?.toString(),
    );
  }
}
