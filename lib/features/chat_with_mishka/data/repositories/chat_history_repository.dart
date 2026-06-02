import 'dart:convert';

import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/chat_session_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/models/chat_history_item.dart';

class ChatHistoryRepository {
  ChatHistoryRepository({ChatSessionRemoteDataSource? sessions})
      : _sessions = sessions ?? ChatSessionRemoteDataSource(ApiService());

  final ChatSessionRemoteDataSource _sessions;

  Future<ChatHistoryData> loadHistory() async {
    final sessions = await _sessions.listSessions();
    final sortedSessions = [...sessions]
      ..sort((a, b) => (b.startedAt ?? '').compareTo(a.startedAt ?? ''));

    if (sortedSessions.isEmpty) {
      return const ChatHistoryData();
    }

    final timelines = await Future.wait(
      sortedSessions.map((session) => _sessions.getTimeline(session.id)),
    );

    final chats = <ChatHistoryItem>[];
    final quizzes = <ChatHistoryItem>[];
    final flashcards = <ChatHistoryItem>[];
    final summaries = <ChatHistoryItem>[];
    final mindmaps = <ChatHistoryItem>[];

    for (var i = 0; i < sortedSessions.length; i++) {
      final session = sortedSessions[i];
      final timeline = timelines[i];
      final sortBase = session.startedAt ?? timeline.messages.lastOrNull?.createdAt ?? '';

      final chatLabel = _chatLabel(session, timeline.messages);
      if (chatLabel.isNotEmpty) {
        chats.add(
          ChatHistoryItem(
            id: session.id,
            label: chatLabel,
            kind: ChatHistoryKind.chat,
            chatSessionId: session.id,
            sortKey: sortBase,
          ),
        );
      }

      for (final msg in timeline.messages) {
        if (msg.inputType != 'tool_preview') continue;

        Map<String, dynamic> data;
        try {
          data = Map<String, dynamic>.from(jsonDecode(msg.messageContent) as Map);
        } catch (_) {
          continue;
        }

        final kind = _kindFromToolData(data);
        if (kind == null) continue;

        final label = _toolLabel(data, session);
        if (label.isEmpty) continue;

        final item = ChatHistoryItem(
          id: '${session.id}:${msg.id}',
          label: label,
          kind: kind,
          chatSessionId: session.id,
          sortKey: msg.createdAt ?? sortBase,
        );

        switch (kind) {
          case ChatHistoryKind.quiz:
            quizzes.add(item);
          case ChatHistoryKind.flashcards:
            flashcards.add(item);
          case ChatHistoryKind.summary:
            summaries.add(item);
          case ChatHistoryKind.mindmap:
            mindmaps.add(item);
          case ChatHistoryKind.chat:
            break;
        }
      }
    }

    void sortNewestFirst(List<ChatHistoryItem> items) {
      items.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    }

    sortNewestFirst(chats);
    sortNewestFirst(quizzes);
    sortNewestFirst(flashcards);
    sortNewestFirst(summaries);
    sortNewestFirst(mindmaps);

    return ChatHistoryData(
      chats: chats,
      quizzes: quizzes,
      flashcards: flashcards,
      summaries: summaries,
      mindmaps: mindmaps,
    );
  }

  String _chatLabel(
    ChatSessionModel session,
    List<ChatTimelineMessage> messages,
  ) {
    for (final msg in messages) {
      if (msg.senderType == 'user' &&
          (msg.inputType == 'text' || msg.inputType.isEmpty)) {
        final text = msg.messageContent.trim();
        if (text.isNotEmpty) return _truncate(text);
      }
    }

    final title = session.title.trim();
    if (title.isNotEmpty && title.toLowerCase() != 'chat') return title;
    final file = session.uploadOriginalFilename?.trim() ?? '';
    if (file.isNotEmpty) return file;
    return title;
  }

  ChatHistoryKind? _kindFromToolData(Map<String, dynamic> data) {
    final raw = (data['tool_type'] ?? '').toString().toLowerCase();
    if (raw.contains('quiz')) return ChatHistoryKind.quiz;
    if (raw.contains('flash')) return ChatHistoryKind.flashcards;
    if (raw.contains('mind')) return ChatHistoryKind.mindmap;
    if (raw.contains('summ')) return ChatHistoryKind.summary;

    if (data['questions'] is List) return ChatHistoryKind.quiz;
    if (data['cards'] is List) return ChatHistoryKind.flashcards;
    if (data['nodes'] is List) return ChatHistoryKind.mindmap;
    if (data['summary'] != null || data['text'] != null) {
      return ChatHistoryKind.summary;
    }
    return null;
  }

  String _toolLabel(Map<String, dynamic> data, ChatSessionModel session) {
    final title = (data['title'] ?? data['name'] ?? '').toString().trim();
    if (title.isNotEmpty) return _truncate(title);

    final summary =
        (data['summary'] ?? data['text'] ?? data['content'] ?? '').toString().trim();
    if (summary.isNotEmpty) return _truncate(summary);

    final file = session.uploadOriginalFilename?.trim();
    if (file != null && file.isNotEmpty) return _truncate(file);

    return _truncate(session.title.trim());
  }

  String _truncate(String value, [int max = 120]) {
    if (value.length <= max) return value;
    return '${value.substring(0, max - 3)}...';
  }
}

extension _LastOrNull<E> on List<E> {
  E? get lastOrNull => isEmpty ? null : last;
}
