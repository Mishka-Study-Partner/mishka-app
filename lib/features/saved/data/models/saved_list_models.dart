import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';

/// List rows from saved-library collection GETs.
class SavedQuizListItem {
  const SavedQuizListItem({
    required this.savedRowId,
    required this.quizId,
    required this.title,
    this.totalQuestions = 0,
    this.sourceFileName,
    this.createdAt,
  });

  final String savedRowId;
  final String quizId;
  final String title;
  final int totalQuestions;
  final String? sourceFileName;
  final DateTime? createdAt;

  factory SavedQuizListItem.fromJson(Map<String, dynamic> json) {
    final quiz = json['quiz'];
    String title = '';
    String? nestedQuizId;
    String? sourceFileName;
    DateTime? createdAt;

    if (quiz is Map<String, dynamic>) {
      title = (quiz['title'] ?? quiz['name'] ?? '').toString();
      nestedQuizId = quiz['id']?.toString();
      createdAt = _readDate(quiz['createdAt'] ?? quiz['savedAt']);
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Quiz').toString();
    }
    sourceFileName = resolveUploadedPdfFileName(json);
    createdAt ??= _readDate(json['createdAt'] ?? json['savedAt']);

    final quizId = (json['quizId'] ??
            nestedQuizId ??
            json['entityId'] ??
            json['id'] ??
            '')
        .toString();

    final quizMap = quiz is Map<String, dynamic> ? quiz : json;
    final totalQuestions = _resolveQuestionCount(quizMap, json);

    return SavedQuizListItem(
      savedRowId: (json['id'] ?? '').toString(),
      quizId: quizId,
      title: title,
      totalQuestions: totalQuestions,
      sourceFileName: sourceFileName,
      createdAt: createdAt,
    );
  }

  SavedQuizListItem copyWith({int? totalQuestions, String? sourceFileName}) {
    return SavedQuizListItem(
      savedRowId: savedRowId,
      quizId: quizId,
      title: title,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAt: createdAt,
    );
  }

  /// Prefer an actual questions array / Prisma `_count` over stale `totalQuestions`.
  static int _resolveQuestionCount(
    Map<String, dynamic> primary,
    Map<String, dynamic> fallback,
  ) {
    for (final map in [primary, fallback]) {
      final fromList = _countQuestionList(
        map['questions'] ?? map['quizQuestions'],
      );
      if (fromList != null) return fromList;

      final count = map['_count'];
      if (count is Map) {
        final nested = _readInt(
          count['questions'] ?? count['quizQuestions'],
        );
        if (nested > 0) return nested;
      }
    }

    for (final map in [primary, fallback]) {
      final synced = _readInt(map['questionCount']);
      if (synced > 0) return synced;

      final declared = _readInt(map['totalQuestions']);
      if (declared > 0) return declared;
    }

    return 0;
  }

  static int? _countQuestionList(Object? raw) {
    if (raw is! List) return null;
    return raw.length;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class SavedFlashcardSetListItem {
  const SavedFlashcardSetListItem({
    required this.savedRowId,
    required this.flashcardSetId,
    required this.title,
    this.sourceFileName,
    this.createdAt,
    this.previewLabels = const [],
  });

  final String savedRowId;
  final String flashcardSetId;
  final String title;
  final String? sourceFileName;
  final DateTime? createdAt;
  final List<String> previewLabels;

  factory SavedFlashcardSetListItem.fromJson(Map<String, dynamic> json) {
    final set = json['flashcardSet'] ?? json['set'];
    String title = '';
    String? nestedId;
    String? sourceFileName;
    DateTime? createdAt;
    List<String> previewLabels = const [];

    if (set is Map<String, dynamic>) {
      title = (set['title'] ?? set['name'] ?? '').toString();
      nestedId = set['id']?.toString();
      createdAt = SavedQuizListItem._readDate(set['createdAt'] ?? set['savedAt']);
      previewLabels = previewLabelsFromFlashcardCards(
        set['flashcards'] ?? set['cards'],
      );
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Flashcards').toString();
    }
    sourceFileName = resolveUploadedPdfFileName(json);
    createdAt ??= SavedQuizListItem._readDate(json['createdAt'] ?? json['savedAt']);
    if (previewLabels.isEmpty) {
      previewLabels = extractFlashcardPreviewLabels(json);
    }

    final flashcardSetId = (json['flashcardSetId'] ??
            json['flashcard_set_id'] ??
            nestedId ??
            json['id'] ??
            '')
        .toString();
    return SavedFlashcardSetListItem(
      savedRowId: (json['id'] ?? '').toString(),
      flashcardSetId: flashcardSetId,
      title: title,
      sourceFileName: sourceFileName,
      createdAt: createdAt,
      previewLabels: previewLabels,
    );
  }

  SavedFlashcardSetListItem copyWith({
    String? sourceFileName,
    DateTime? createdAt,
    List<String>? previewLabels,
  }) {
    return SavedFlashcardSetListItem(
      savedRowId: savedRowId,
      flashcardSetId: flashcardSetId,
      title: title,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAt: createdAt ?? this.createdAt,
      previewLabels: previewLabels ?? this.previewLabels,
    );
  }
}

class SavedSummaryListItem {
  const SavedSummaryListItem({
    required this.savedRowId,
    required this.summaryId,
    required this.title,
    this.sourceFileName,
    this.createdAt,
    this.snippet = '',
  });

  final String savedRowId;
  final String summaryId;
  final String title;
  final String? sourceFileName;
  final DateTime? createdAt;
  final String snippet;

  factory SavedSummaryListItem.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'];
    String title = '';
    String? nestedId;
    String? sourceFileName;
    DateTime? createdAt;
    String? summaryText;

    if (summary is Map<String, dynamic>) {
      title = (summary['title'] ?? summary['name'] ?? '').toString();
      nestedId = summary['id']?.toString();
      createdAt = SavedQuizListItem._readDate(summary['createdAt'] ?? summary['savedAt']);
      summaryText = _readSummaryText(summary);
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Summary').toString();
    }
    sourceFileName = resolveUploadedPdfFileName(json);
    createdAt ??= SavedQuizListItem._readDate(json['createdAt'] ?? json['savedAt']);
    summaryText ??= _readSummaryText(json);

    final summaryId = (json['summaryId'] ??
            json['summary_id'] ??
            nestedId ??
            json['id'] ??
            '')
        .toString();
    return SavedSummaryListItem(
      savedRowId: (json['id'] ?? '').toString(),
      summaryId: summaryId,
      title: title,
      sourceFileName: sourceFileName,
      createdAt: createdAt,
      snippet: snippetFromSummaryText(summaryText),
    );
  }

  static String? _readSummaryText(Map<String, dynamic> map) {
    for (final key in const ['summaryText', 'text', 'content', 'summary']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  SavedSummaryListItem copyWith({String? sourceFileName, String? snippet}) {
    return SavedSummaryListItem(
      savedRowId: savedRowId,
      summaryId: summaryId,
      title: title,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAt: createdAt,
      snippet: snippet ?? this.snippet,
    );
  }
}

class SavedMindMapListItem {
  const SavedMindMapListItem({
    required this.savedRowId,
    required this.mindMapId,
    required this.title,
    this.sourceFileName,
    this.createdAt,
    this.snippet = '',
  });

  final String savedRowId;
  final String mindMapId;
  final String title;
  final String? sourceFileName;
  final DateTime? createdAt;
  final String snippet;

  factory SavedMindMapListItem.fromJson(Map<String, dynamic> json) {
    final mm = json['mindMap'] ?? json['mind_map'];
    String title = '';
    String? nestedId;
    String? sourceFileName;
    DateTime? createdAt;

    if (mm is Map<String, dynamic>) {
      title = (mm['title'] ?? mm['name'] ?? '').toString();
      nestedId = mm['id']?.toString();
      createdAt = SavedQuizListItem._readDate(mm['createdAt'] ?? mm['savedAt']);
    }
    if (title.isEmpty) {
      title = (json['title'] ?? json['name'] ?? 'Mind map').toString();
    }
    sourceFileName = resolveUploadedPdfFileName(json);
    createdAt ??= SavedQuizListItem._readDate(json['createdAt'] ?? json['savedAt']);

    final mindMapId = (json['mindMapId'] ??
            json['mind_map_id'] ??
            nestedId ??
            json['id'] ??
            '')
        .toString();
    return SavedMindMapListItem(
      savedRowId: (json['id'] ?? '').toString(),
      mindMapId: mindMapId,
      title: title,
      sourceFileName: sourceFileName,
      createdAt: createdAt,
      snippet: snippetFromMindMapRaw(json),
    );
  }

  SavedMindMapListItem copyWith({String? sourceFileName, String? snippet}) {
    return SavedMindMapListItem(
      savedRowId: savedRowId,
      mindMapId: mindMapId,
      title: title,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      createdAt: createdAt,
      snippet: snippet ?? this.snippet,
    );
  }
}
