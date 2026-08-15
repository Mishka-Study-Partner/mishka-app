import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/chat_session_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';

/// Resolves [uploadOriginalFilename] from saved payloads, including a chat-session
/// timeline fetch when the backend only returns [chatSessionId].
class SavedUploadFilenameResolver {
  SavedUploadFilenameResolver({ChatSessionRemoteDataSource? chatSessions})
      : _chatSessions = chatSessions ?? ChatSessionRemoteDataSource(ApiService());

  final ChatSessionRemoteDataSource _chatSessions;
  final Map<String, String?> _sessionCache = {};

  Future<String?> resolve(Map<String, dynamic> raw) async {
    final inline = resolveUploadedPdfFileName(raw);
    if (inline != null && inline.isNotEmpty) return inline;

    final sessionId = extractChatSessionId(raw);
    if (sessionId == null || sessionId.isEmpty) return null;

    if (_sessionCache.containsKey(sessionId)) {
      return _sessionCache[sessionId];
    }

    try {
      final timeline = await _chatSessions.getTimeline(sessionId);
      final fromSession =
          timeline.session.uploadOriginalFilename?.trim();
      if (fromSession != null && fromSession.isNotEmpty) {
        _sessionCache[sessionId] = fromSession;
        return fromSession;
      }

      for (final msg in timeline.messages) {
        if (msg.inputType == 'file') {
          final fileName = msg.messageContent.trim();
          if (fileName.isNotEmpty) {
            _sessionCache[sessionId] = fileName;
            return fileName;
          }
        }
      }
    } catch (_) {
      // Ignore — caller falls back to empty PDF label.
    }

    _sessionCache[sessionId] = null;
    return null;
  }
}

/// Reads [chatSessionId] from a saved-library list or detail payload.
String? extractChatSessionId(Map<String, dynamic> raw) {
  String? pick(Map<String, dynamic> map) {
    for (final key in const ['chatSessionId', 'chat_session_id']) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    final session = map['chatSession'];
    if (session is Map) {
      final sessionId = session['id']?.toString().trim();
      if (sessionId != null && sessionId.isNotEmpty) return sessionId;
    }
    return null;
  }

  final direct = pick(raw);
  if (direct != null) return direct;

  for (final key in const [
    'quiz',
    'flashcardSet',
    'flashcard_set',
    'set',
    'summary',
    'mindMap',
    'mind_map',
  ]) {
    final nested = raw[key];
    if (nested is Map) {
      final fromNested = pick(Map<String, dynamic>.from(nested));
      if (fromNested != null) return fromNested;
    }
  }
  return null;
}
