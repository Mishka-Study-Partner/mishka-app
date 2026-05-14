import 'dart:convert';

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
}
