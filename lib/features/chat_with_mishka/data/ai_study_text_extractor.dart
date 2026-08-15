/// Parses readable study text from AI worker JSON (`/upload`, `/generate-tools`).
abstract final class AiStudyTextExtractor {
  AiStudyTextExtractor._();

  static Map<String, dynamic> unwrapPayload(Map<String, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);
    for (final key in const ['data', 'result', 'tool', 'payload']) {
      final nested = data[key];
      if (nested is Map) {
        data.addAll(Map<String, dynamic>.from(nested));
        break;
      }
    }
    return data;
  }

  /// Body text for summary / upload explanation bubbles.
  static String? extractUploadExplanation(Map<String, dynamic> raw) {
    final data = unwrapPayload(raw);
    final sessionId = (data['session_id'] ?? data['sessionId'] ?? '').toString();
    if (sessionId.isEmpty && data.isEmpty) return null;

    final explicit = data['summaryText'];
    if (explicit is String && explicit.trim().isNotEmpty) {
      return explicit.trim();
    }

    final candidates = <String>[];
    for (final key in const [
      'explanation',
      'content',
      'summary',
      'text',
      'body',
      'markdown',
      'response',
    ]) {
      final resolved = coerceStudyText(data[key]);
      if (resolved != null && resolved.trim().isNotEmpty) {
        candidates.add(resolved.trim());
      }
    }

    return _longestMeaningful(candidates);
  }

  /// Resolves summary body from generate-tools / saved payloads.
  static String? resolveSummaryBody(Map<String, dynamic> data) {
    final explicit = data['summaryText'];
    if (explicit is String && explicit.trim().isNotEmpty) {
      return explicit.trim();
    }

    final candidates = <String>[];

    for (final key in const ['explanation', 'content', 'summary', 'text', 'body']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        candidates.add(value.trim());
      } else {
        final resolved = coerceStudyText(value);
        if (resolved != null && resolved.trim().isNotEmpty) {
          candidates.add(resolved.trim());
        }
      }
    }

    return _longestMeaningful(candidates);
  }

  static String? coerceStudyText(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (_looksLikeSerializedMap(trimmed)) return null;
      return trimmed;
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in const [
        'text',
        'content',
        'body',
        'summary',
        'explanation',
        'markdown',
        'value',
      ]) {
        final nested = coerceStudyText(map[key]);
        if (nested != null && nested.trim().isNotEmpty) return nested.trim();
      }
      return null;
    }
    if (value is List) {
      final parts = <String>[];
      for (final item in value) {
        final text = coerceStudyText(item);
        if (text != null && text.trim().isNotEmpty) {
          parts.add(text.trim());
        }
      }
      if (parts.isEmpty) return null;
      return parts.join('\n\n');
    }
    final asString = value.toString().trim();
    if (asString.isEmpty || _looksLikeSerializedMap(asString)) return null;
    return asString;
  }

  static String? _longestMeaningful(List<String> candidates) {
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  static bool _looksLikeSerializedMap(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) return false;
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }
}
