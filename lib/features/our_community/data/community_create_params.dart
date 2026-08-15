/// Discovery fields for `POST /communities` (public communities).
class CommunityCreateParams {
  const CommunityCreateParams({
    this.subjectKeys = const [],
    this.educationStatus,
    this.schoolTrack,
    this.schoolGrade,
    this.universityYear,
    this.purpose,
    this.locale,
    this.category,
    this.newCategoryTitle,
  });

  final List<String> subjectKeys;
  final String? educationStatus;
  final String? schoolTrack;
  final int? schoolGrade;
  final int? universityYear;
  final String? purpose;
  final String? locale;
  /// Existing title from `GET /communities/category-titles`.
  final String? category;
  /// New display category (mutually exclusive with [category]).
  final String? newCategoryTitle;

  bool get hasDiscoveryFields =>
      subjectKeys.isNotEmpty ||
      (educationStatus != null && educationStatus!.isNotEmpty) ||
      (purpose != null && purpose!.isNotEmpty) ||
      (category != null && category!.isNotEmpty) ||
      (newCategoryTitle != null && newCategoryTitle!.isNotEmpty);
}
