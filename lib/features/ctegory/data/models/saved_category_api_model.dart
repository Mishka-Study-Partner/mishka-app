class SavedCategoryApiModel {
  const SavedCategoryApiModel({
    required this.id,
    required this.categoryId,
  });

  final String id;
  final String categoryId;

  factory SavedCategoryApiModel.fromJson(Map<String, dynamic> json) {
    String categoryId = (json['categoryId'] ?? '').toString();
    final category = json['category'];
    if ((categoryId.isEmpty || categoryId == 'null') && category is Map) {
      categoryId = (category['id'] ?? '').toString();
    }
    return SavedCategoryApiModel(
      id: (json['id'] ?? '').toString(),
      categoryId: categoryId,
    );
  }
}
