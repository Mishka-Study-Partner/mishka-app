import 'dart:convert';

import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

/// Envelope `data` from `GET /saved-quizzes/{id}` (etc.): full tutor row + nested content.
class SavedLibraryDetail {
  const SavedLibraryDetail(this.raw);

  final Map<String, dynamic> raw;

  /// Prefer nested entity title; fall back to list title fields or [fallback].
  String resolvedTitle(String fallback) {
    final nestedKeys = [
      'quiz',
      'flashcardSet',
      'flashcard_set',
      'set',
      'summary',
      'mindMap',
      'mind_map',
    ];
    for (final key in nestedKeys) {
      final n = raw[key];
      if (n is Map) {
        final m = Map<String, dynamic>.from(n);
        final t = (m['title'] ?? m['name'] ?? '').toString();
        if (t.isNotEmpty) return t;
      }
    }
    final top = (raw['title'] ?? raw['name'] ?? '').toString();
    if (top.isNotEmpty) return top;
    return fallback;
  }

  String get formattedJson {
    try {
      return const JsonEncoder.withIndent('  ').convert(raw);
    } catch (_) {
      return raw.toString();
    }
  }

  String? tutorEntityId(SavedContentKind kind) {
    switch (kind) {
      case SavedContentKind.quiz:
        return _readId(raw['quizId'], raw['quiz']);
      case SavedContentKind.flashcards:
        return _readId(
          raw['flashcardSetId'] ?? raw['flashcard_set_id'],
          raw['flashcardSet'] ?? raw['flashcard_set'] ?? raw['set'],
        );
      case SavedContentKind.summary:
        return _readId(raw['summaryId'] ?? raw['summary_id'], raw['summary']);
      case SavedContentKind.mindmap:
        return _readId(
          raw['mindMapId'] ?? raw['mind_map_id'],
          raw['mindMap'] ?? raw['mind_map'],
        );
    }
  }

  static String? _readId(Object? direct, Object? nested) {
    if (direct != null && direct.toString().trim().isNotEmpty) {
      return direct.toString();
    }
    if (nested is Map) {
      final id = nested['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString();
      }
    }
    return null;
  }
}
