import 'dart:convert';

import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/models/chat_history_item.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';

/// Reads tool usage from chat sessions in one request (messages are embedded in list).
class ReportAiActivityDataSource {
  ReportAiActivityDataSource(this._api);

  final ApiService _api;

  Future<AiToolReportStats> countToolsInRange({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final env = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.chatSessions,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    final sessions = env.data ?? const [];

    var quizzes = 0;
    var flashcards = 0;
    var summaries = 0;
    var mindMaps = 0;

    for (final session in sessions) {
      final messages = (session['messages'] as List?) ?? const [];
      for (final raw in messages.whereType<Map>()) {
        final msg = Map<String, dynamic>.from(raw);
        if ((msg['inputType'] ?? '').toString() != 'tool_preview') continue;

        final createdAt = DateTime.tryParse((msg['createdAt'] ?? '').toString());
        if (createdAt != null) {
          final utc = createdAt.toUtc();
          if (utc.isBefore(rangeStart) || !utc.isBefore(rangeEnd)) continue;
        }

        Map<String, dynamic> data;
        try {
          data = Map<String, dynamic>.from(
            jsonDecode(msg['messageContent'].toString()) as Map,
          );
        } catch (_) {
          continue;
        }

        final kind = _kindFromToolData(data);
        switch (kind) {
          case ChatHistoryKind.quiz:
            quizzes++;
          case ChatHistoryKind.flashcards:
            flashcards++;
          case ChatHistoryKind.summary:
            summaries++;
          case ChatHistoryKind.mindmap:
            mindMaps++;
          case ChatHistoryKind.chat:
          case null:
            break;
        }
      }
    }

    return AiToolReportStats(
      quizzes: quizzes,
      flashcards: flashcards,
      summaries: summaries,
      mindMaps: mindMaps,
    );
  }

  ChatHistoryKind? _kindFromToolData(Map<String, dynamic> data) {
    final raw = (data['tool_type'] ?? data['toolType'] ?? '').toString().toLowerCase();
    if (raw.contains('flash')) return ChatHistoryKind.flashcards;
    if (raw.contains('quiz')) return ChatHistoryKind.quiz;
    if (raw.contains('mind')) return ChatHistoryKind.mindmap;
    if (raw.contains('summ')) return ChatHistoryKind.summary;
    if (data['questions'] != null) return ChatHistoryKind.quiz;
    if (data['cards'] != null) return ChatHistoryKind.flashcards;
    if (data['root'] != null || data['nodes'] != null) {
      return ChatHistoryKind.mindmap;
    }
    if (data['summary'] != null || data['text'] != null) {
      return ChatHistoryKind.summary;
    }
    return null;
  }
}
