import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_response_helpers.dart';
import 'package:mishka_app/features/chat_with_mishka/data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/generate_tools_result.dart';

/// Mishka backend proxy for AI tool generation (creates `tool_preview` message).
class GenerateToolsRemoteDataSource {
  GenerateToolsRemoteDataSource(this._api);

  final ApiService _api;

  Future<GenerateToolsResult> generateTool({
    required String aiSessionId,
    required String chatSessionId,
    required StudyAction action,
    required String complexity,
  }) async {
    try {
      final env = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.generateTools,
        data: {
          'session_id': aiSessionId,
          'tool_type': _toolType(action),
          'complexity': complexity,
        },
        dataFromJson: (raw) {
          if (raw is Map) {
            return Map<String, dynamic>.from(raw);
          }
          throw const FormatException('Invalid generate-tools response');
        },
      );
      final payload = env.data ?? const <String, dynamic>{};
      return parseGenerateToolsResponse(
        payload,
        chatSessionId: chatSessionId,
      );
    } on ApiException catch (e) {
      throw _mapGenerateToolsError(e);
    }
  }

  Exception _mapGenerateToolsError(ApiException e) {
    switch (e.error) {
      case 'AI_SESSION_NOT_FOUND':
        return const AiSessionNotFoundException();
      case 'CHAT_SESSION_NOT_FOUND':
        return const ChatSessionNotFoundException();
      default:
        return e;
    }
  }

  String _toolType(StudyAction action) {
    return switch (action) {
      StudyAction.quiz => 'quizzes',
      StudyAction.flashcards => 'flashcards',
      StudyAction.mindmap => 'mind_maps',
      StudyAction.summarize => 'summaries',
    };
  }
}
