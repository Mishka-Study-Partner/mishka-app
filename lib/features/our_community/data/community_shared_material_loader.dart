import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/our_community/data/community_json_helpers.dart';
import 'package:mishka_app/features/our_community/data/community_material_ref.dart';
import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

/// Loads tutor entity payloads for shared `inputType: material` channel messages.
class CommunitySharedMaterialLoader {
  CommunitySharedMaterialLoader({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>?> loadToolData(CommunityMaterialRef ref) async {
    final kind = _kindFromApiType(ref.materialType);
    if (kind == null) return null;

    return switch (kind) {
      SavedContentKind.quiz => _loadQuiz(ref.materialId),
      SavedContentKind.flashcards => _loadFlashcards(ref.materialId),
      SavedContentKind.summary => _loadSummary(ref.materialId),
      SavedContentKind.mindmap => _loadMindMap(ref.materialId),
    };
  }

  SavedContentKind? _kindFromApiType(String raw) {
    final t = raw.trim().toLowerCase();
    if (t == 'quiz' || t == 'quizzes') return SavedContentKind.quiz;
    if (t == 'flashcard_set' ||
        t == 'flashcard-set' ||
        t == 'flashcards' ||
        t == 'flashcard') {
      return SavedContentKind.flashcards;
    }
    if (t == 'summary' || t == 'summaries') return SavedContentKind.summary;
    if (t == 'mind_map' || t == 'mind-map' || t == 'mindmap' || t == 'mind_maps') {
      return SavedContentKind.mindmap;
    }
    return null;
  }

  Future<Map<String, dynamic>?> _loadQuiz(String quizId) async {
    final quiz = await _fetchMap(ApiEndpoints.quizById(quizId));
    if (quiz == null) return null;

    final questions = await _fetchList(ApiEndpoints.quizQuestionsForQuiz(quizId));
    final payload = <String, dynamic>{
      'quizId': quizId,
      'quiz': quiz,
      if (questions.isNotEmpty) 'questions': questions,
    };

    return buildQuizToolDataFromSavedDetail(payload) ??
        normalizeToolData({
          'tool_type': 'quizzes',
          'title': quiz['title'] ?? 'Quiz',
          'questions': questions,
          'quizId': quizId,
        });
  }

  Future<Map<String, dynamic>?> _loadFlashcards(String setId) async {
    var set = await _fetchMap(ApiEndpoints.flashcardSetById(setId));
    var cards = set != null
        ? await _fetchList(ApiEndpoints.flashcardSetFlashcards(setId))
        : const <Map<String, dynamic>>[];

    if (set == null) {
      final saved = await _fetchMap(ApiEndpoints.savedFlashcardSetDetailById(setId));
      if (saved == null) return null;
      set = saved;
      final inline = saved['flashcards'] ?? saved['cards'];
      if (inline is List) {
        cards = inline
            .whereType<Map>()
            .map((card) => Map<String, dynamic>.from(card))
            .toList();
      }
    }

    final payload = <String, dynamic>{
      'flashcardSetId': setId,
      'flashcardSet': set,
      if (cards.isNotEmpty) 'cards': cards,
      if (cards.isNotEmpty) 'flashcards': cards,
    };

    return buildFlashcardToolDataFromSavedDetail(payload) ??
        normalizeToolData({
          'tool_type': 'flashcards',
          'title': set['title'] ?? 'Flashcards',
          'cards': cards,
          'flashcardSetId': setId,
        });
  }

  Future<Map<String, dynamic>?> _loadSummary(String summaryId) async {
    final summary = await _fetchMap(ApiEndpoints.summaryById(summaryId));
    if (summary == null) return null;

    return buildSummaryToolDataFromSavedDetail({
          'summaryId': summaryId,
          'summary': summary,
        }) ??
        normalizeToolData({
          'tool_type': 'summaries',
          'title': summary['title'] ?? 'Summary',
          'summaryText': summary['summaryText'] ?? summary['text'] ?? '',
          'summaryId': summaryId,
        });
  }

  Future<Map<String, dynamic>?> _loadMindMap(String mindMapId) async {
    final mindMap = await _fetchMap(ApiEndpoints.mindMapById(mindMapId));
    if (mindMap == null) return null;

    return buildMindMapToolDataFromSavedDetail({
          'mindMapId': mindMapId,
          'mindMap': mindMap,
        }) ??
        normalizeToolData({
          'tool_type': 'mind_maps',
          'title': mindMap['title'] ?? 'Mind Map',
          'content': mindMap['content'],
          'mindMapId': mindMapId,
        });
  }

  Future<Map<String, dynamic>?> _fetchMap(String path) async {
    final env = await _api.get<Map<String, dynamic>>(
      path,
      dataFromJson: mapFromRawOrEmpty,
    );
    final data = env.data;
    if (data == null || data.isEmpty) return null;
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final env = await _api.get<List<Map<String, dynamic>>>(
      path,
      dataFromJson: listOfMapsFromRaw,
    );
    return env.data ?? const [];
  }
}
