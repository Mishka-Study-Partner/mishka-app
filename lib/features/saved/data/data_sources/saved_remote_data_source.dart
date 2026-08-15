import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/saved/data/models/quiz_submit_outcome.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/models/saved_list_models.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

class SavedRemoteDataSource {
  SavedRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<SavedQuizListItem>> getSavedQuizzes() async {
    final env = await _api.get<List<SavedQuizListItem>>(
      ApiEndpoints.savedQuizzes,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedQuizListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedFlashcardSetListItem>> getSavedFlashcardSets() async {
    final env = await _api.get<List<SavedFlashcardSetListItem>>(
      ApiEndpoints.savedFlashcardSets,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedFlashcardSetListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedSummaryListItem>> getSavedSummaries() async {
    final env = await _api.get<List<SavedSummaryListItem>>(
      ApiEndpoints.savedSummaries,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedSummaryListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedMindMapListItem>> getSavedMindMaps() async {
    final env = await _api.get<List<SavedMindMapListItem>>(
      ApiEndpoints.savedMindMaps,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => SavedMindMapListItem.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Map<String, dynamic> _mapDataFromJson(Object? raw) {
    if (raw == null) {
      return {};
    }
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  Future<SavedLibraryDetail> getSavedQuizDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedQuizDetailById(savedListRowId));

  Future<SavedLibraryDetail> getSavedFlashcardSetDetail(
    String savedListRowId,
  ) =>
      _fetchSavedLibraryDetail(
        ApiEndpoints.savedFlashcardSetDetailById(savedListRowId),
      );

  Future<SavedLibraryDetail> getSavedSummaryDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedSummaryDetailById(
        savedListRowId,
      ));

  Future<SavedLibraryDetail> getSavedMindMapDetail(String savedListRowId) =>
      _fetchSavedLibraryDetail(ApiEndpoints.savedMindMapDetailById(
        savedListRowId,
      ));

  Future<SavedLibraryDetail> _fetchSavedLibraryDetail(String path) async {
    final env = await _api.get<Map<String, dynamic>>(
      path,
      dataFromJson: _mapDataFromJson,
    );
    final data = env.data;
    if (data == null || data.isEmpty) {
      throw ApiException(
        message: 'No data for this saved item',
        error: 'EMPTY_DATA',
      );
    }
    return SavedLibraryDetail(data);
  }

  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    if (quizId.isEmpty) return const [];

    final env = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.quizQuestionsForQuiz(quizId),
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<int?> getQuizBestScorePercent(String quizId) async {
    if (quizId.isEmpty) return null;

    final env = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.quizAttemptsForQuiz(quizId),
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    final attempts = env.data ?? const [];
    if (attempts.isEmpty) return null;

    int? best;
    for (final row in attempts) {
      final scoreTen = row['scoreOutOfTen'];
      final percentage = row['percentage'];
      int? percent;
      if (percentage is num) {
        percent = percentage.round();
      } else if (scoreTen is num) {
        percent = (scoreTen * 10).round();
      }
      if (percent != null && (best == null || percent > best)) {
        best = percent;
      }
    }
    final envelopeBest = attempts.first['bestScoreOutOfTen'];
    if (envelopeBest is num) {
      final fromBest = (envelopeBest * 10).round();
      if (best == null || fromBest > best) best = fromBest;
    }
    return best;
  }

  Future<QuizSubmitOutcome?> submitQuizAttempt({
    required String quizId,
    required List<Map<String, dynamic>> questions,
    required Map<int, int> selectedAnswers,
  }) async {
    if (quizId.isEmpty) return null;

    final answers = <Map<String, dynamic>>[];
    for (var i = 0; i < questions.length; i++) {
      final questionId = questions[i]['id']?.toString();
      final selected = selectedAnswers[i];
      if (questionId == null ||
          questionId.isEmpty ||
          selected == null ||
          selected < 0 ||
          selected > 3) {
        continue;
      }
      answers.add({
        'questionId': questionId,
        'selectedOption': String.fromCharCode(65 + selected),
      });
    }
    if (answers.length != questions.length) return null;

    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.quizSubmit(quizId),
      data: {'answers': answers},
      dataFromJson: _mapDataFromJson,
    );
    final data = env.data;
    if (data == null) return null;

    int percent = 0;
    final percentage = data['percentage'];
    if (percentage is num) {
      percent = percentage.round();
    } else {
      final scoreTen = data['scoreOutOfTen'];
      if (scoreTen is num) percent = (scoreTen * 10).round();
    }

    final attemptId = (data['attemptId'] ??
            data['attempt_id'] ??
            data['id'] ??
            data['quizAttemptId'])
        ?.toString();

    return QuizSubmitOutcome(percent: percent, attemptId: attemptId);
  }

  Future<void> renameTutorEntity({
    required SavedContentKind kind,
    required String entityId,
    required String title,
  }) async {
    final path = switch (kind) {
      SavedContentKind.quiz => ApiEndpoints.quizById(entityId),
      SavedContentKind.flashcards => ApiEndpoints.flashcardSetById(entityId),
      SavedContentKind.summary => ApiEndpoints.summaryById(entityId),
      SavedContentKind.mindmap => ApiEndpoints.mindMapById(entityId),
    };
    await _api.put<void>(path, data: {'title': title.trim()});
  }

  /// `DELETE /saved-*/{id}` — [savedListRowId] is the list row `id`.
  Future<void> deleteSavedLibraryRow(
    SavedContentKind kind,
    String savedListRowId,
  ) async {
    final path = switch (kind) {
      SavedContentKind.flashcards =>
        ApiEndpoints.savedFlashcardSetDetailById(savedListRowId),
      SavedContentKind.quiz =>
        ApiEndpoints.savedQuizDetailById(savedListRowId),
      SavedContentKind.summary =>
        ApiEndpoints.savedSummaryDetailById(savedListRowId),
      SavedContentKind.mindmap =>
        ApiEndpoints.savedMindMapDetailById(savedListRowId),
    };
    await _api.delete<void>(path);
  }
}
