/// List rows from saved-library collection GETs.
class SavedQuizListItem {
  const SavedQuizListItem({
    required this.savedRowId,
    required this.quizId,
    required this.title,
  });

  final String savedRowId;
  final String quizId;
  final String title;

  factory SavedQuizListItem.fromJson(Map<String, dynamic> json) {
    final quiz = json['quiz'];
    String title = '';
    String? nestedQuizId;
    if (quiz is Map<String, dynamic>) {
      title = (quiz['title'] ?? quiz['name'] ?? '').toString();
      nestedQuizId = quiz['id']?.toString();
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Quiz').toString();
    }
    final quizId =
        (json['quizId'] ?? nestedQuizId ?? json['entityId'] ?? '').toString();
    return SavedQuizListItem(
      savedRowId: (json['id'] ?? '').toString(),
      quizId: quizId,
      title: title,
    );
  }
}

class SavedFlashcardSetListItem {
  const SavedFlashcardSetListItem({
    required this.savedRowId,
    required this.flashcardSetId,
    required this.title,
  });

  final String savedRowId;
  final String flashcardSetId;
  final String title;

  factory SavedFlashcardSetListItem.fromJson(Map<String, dynamic> json) {
    final set = json['flashcardSet'] ?? json['set'];
    String title = '';
    String? nestedId;
    if (set is Map<String, dynamic>) {
      title = (set['title'] ?? set['name'] ?? '').toString();
      nestedId = set['id']?.toString();
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Flashcards').toString();
    }
    final flashcardSetId = (json['flashcardSetId'] ??
            json['flashcard_set_id'] ??
            nestedId ??
            '')
        .toString();
    return SavedFlashcardSetListItem(
      savedRowId: (json['id'] ?? '').toString(),
      flashcardSetId: flashcardSetId,
      title: title,
    );
  }
}

class SavedSummaryListItem {
  const SavedSummaryListItem({
    required this.savedRowId,
    required this.summaryId,
    required this.title,
  });

  final String savedRowId;
  final String summaryId;
  final String title;

  factory SavedSummaryListItem.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'];
    String title = '';
    String? nestedId;
    if (summary is Map<String, dynamic>) {
      title = (summary['title'] ?? summary['name'] ?? '').toString();
      nestedId = summary['id']?.toString();
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Summary').toString();
    }
    final summaryId =
        (json['summaryId'] ?? json['summary_id'] ?? nestedId ?? '').toString();
    return SavedSummaryListItem(
      savedRowId: (json['id'] ?? '').toString(),
      summaryId: summaryId,
      title: title,
    );
  }
}

class SavedMindMapListItem {
  const SavedMindMapListItem({
    required this.savedRowId,
    required this.mindMapId,
    required this.title,
  });

  final String savedRowId;
  final String mindMapId;
  final String title;

  factory SavedMindMapListItem.fromJson(Map<String, dynamic> json) {
    final mm = json['mindMap'] ?? json['mind_map'];
    String title = '';
    String? nestedId;
    if (mm is Map<String, dynamic>) {
      title = (mm['title'] ?? mm['name'] ?? '').toString();
      nestedId = mm['id']?.toString();
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Mind map').toString();
    }
    final mindMapId = (json['mindMapId'] ??
            json['mind_map_id'] ??
            nestedId ??
            '')
        .toString();
    return SavedMindMapListItem(
      savedRowId: (json['id'] ?? '').toString(),
      mindMapId: mindMapId,
      title: title,
    );
  }
}
