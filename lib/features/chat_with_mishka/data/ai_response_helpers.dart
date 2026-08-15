/// Detects upstream model-provider failures returned inside HTTP 200 bodies.
class AiServiceException implements Exception {
  const AiServiceException({this.detail});

  final String? detail;

  @override
  String toString() => detail ?? 'AiServiceException';
}

/// AI server no longer has the PDF session (expired, restart, or failed upload).
class AiSessionNotFoundException implements Exception {
  const AiSessionNotFoundException();
}

/// Mishka chat session missing or inactive when generating tools.
class ChatSessionNotFoundException implements Exception {
  const ChatSessionNotFoundException();
}

abstract final class AiResponseHelpers {
  static bool looksLikeProviderError(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('openrouter api error')) return true;
    if (lower.contains('error code: 401') ||
        lower.contains('error code: 403') ||
        lower.contains('error code: 429') ||
        lower.contains('error code: 500') ||
        lower.contains('error code: 502') ||
        lower.contains('error code: 503')) {
      return true;
    }
    if (lower.contains('invalid api key') ||
        lower.contains('incorrect api key') ||
        lower.contains('authentication failed') ||
        lower.contains('user not found') && lower.contains('401')) {
      return true;
    }
    if (lower.contains('rate limit') || lower.contains('insufficient quota')) {
      return true;
    }
    return false;
  }

  static bool looksLikeConnectionFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('connection reset') ||
        text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection refused') ||
        text.contains('connection timed out') ||
        text.contains('application failed to respond') ||
        text.contains('handshake exception');
  }

  static void throwIfProviderError(String text, {String? field}) {
    if (!looksLikeProviderError(text)) return;
    throw AiServiceException(
      detail: field == null ? text : '$field: $text',
    );
  }

  static String displayText(String text, String fallback) {
    if (looksLikeProviderError(text)) return fallback;
    return text;
  }
}
