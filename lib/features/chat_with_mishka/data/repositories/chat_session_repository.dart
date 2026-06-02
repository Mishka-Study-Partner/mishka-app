import 'dart:convert';

import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/chat_with_mishka/data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/chat_session_remote_data_source.dart';

class ChatSessionRepository {
  ChatSessionRepository({ChatSessionRemoteDataSource? remote})
      : _remote = remote ?? ChatSessionRemoteDataSource(ApiService());

  final ChatSessionRemoteDataSource _remote;

  Future<ChatSessionModel> startSession({
    required String title,
    String? uploadOriginalFilename,
  }) async {
    return _remote.createSession(
      title: title,
      uploadOriginalFilename: uploadOriginalFilename,
    );
  }

  Future<List<ChatSessionModel>> listSessions() => _remote.listSessions();

  Future<({ChatSessionTimeline timeline, String? aiSessionId})> loadSession(
    String sessionId,
  ) async {
    final timeline = await _remote.getTimeline(sessionId);
    String? aiSessionId;
    for (final msg in timeline.messages) {
      if (msg.inputType == 'session_meta') {
        try {
          final meta = jsonDecode(msg.messageContent) as Map<String, dynamic>;
          final fromMeta = meta['aiSessionId']?.toString();
          if (fromMeta != null && fromMeta.isNotEmpty) {
            aiSessionId = fromMeta;
          }
        } catch (_) {}
        break;
      }
    }
    if (aiSessionId != null && aiSessionId.isNotEmpty) {
      await AppPreferences.setActiveChatSession(
        backendSessionId: sessionId,
        aiSessionId: aiSessionId,
      );
    } else {
      await AppPreferences.setChatBackendSessionId(sessionId);
    }
    return (timeline: timeline, aiSessionId: aiSessionId);
  }

  Future<({ChatSessionTimeline timeline, String? aiSessionId})?> loadActiveSession() async {
    final backendId = AppPreferences.chatBackendSessionId;
    if (backendId == null || backendId.isEmpty) return null;

    try {
      final timeline = await _remote.getTimeline(backendId);
      if (!timeline.session.isActive) return null;

      String? aiSessionId = AppPreferences.chatAiSessionId;
      for (final msg in timeline.messages) {
        if (msg.inputType == 'session_meta') {
          try {
            final meta = jsonDecode(msg.messageContent) as Map<String, dynamic>;
            final fromMeta = meta['aiSessionId']?.toString();
            if (fromMeta != null && fromMeta.isNotEmpty) {
              aiSessionId = fromMeta;
            }
          } catch (_) {}
          break;
        }
      }

      return (timeline: timeline, aiSessionId: aiSessionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> bindAiSession({
    required String backendSessionId,
    required String aiSessionId,
    DifficultyLevel? difficulty,
  }) async {
    await AppPreferences.setActiveChatSession(
      backendSessionId: backendSessionId,
      aiSessionId: aiSessionId,
    );
    await _remote.createMessage(
      sessionId: backendSessionId,
      senderType: 'ai',
      messageContent: jsonEncode({
        'aiSessionId': aiSessionId,
        if (difficulty != null) 'difficulty': difficulty.name,
      }),
      inputType: 'session_meta',
    );
  }

  Future<void> persistMessage({
    required String backendSessionId,
    required ChatMessage message,
  }) async {
    final senderType = message.isFromMishka ? 'ai' : 'user';
    switch (message.type) {
      case MessageType.text:
      case MessageType.explanation:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: senderType,
          messageContent: message.text ?? '',
          inputType: message.type == MessageType.explanation
              ? 'explanation'
              : 'text',
        );
      case MessageType.system:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: 'ai',
          messageContent: message.text ?? '',
          inputType: 'system',
        );
      case MessageType.file:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: 'user',
          messageContent: message.fileName ?? '',
          inputType: 'file',
        );
      case MessageType.options:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: 'ai',
          messageContent: jsonEncode(message.options ?? const []),
          inputType: 'options',
        );
      case MessageType.selection:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: 'user',
          messageContent: message.selectedOption ?? '',
          inputType: 'selection',
        );
      case MessageType.toolPreview:
        await _remote.createMessage(
          sessionId: backendSessionId,
          senderType: 'ai',
          messageContent: jsonEncode(message.toolData ?? const {}),
          inputType: 'tool_preview',
        );
    }
  }
}
