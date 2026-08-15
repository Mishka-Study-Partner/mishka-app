/// Thrown when the API returns `success: false` or a non-envelope / network failure.
/// Use [error] for logic; use [message] for UI (already localized by backend from [Accept-Language]).
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.error,
    this.details,
    this.statusCode,
  });

  final String message;
  final String? error;
  final dynamic details;
  final int? statusCode;

  @override
  String toString() => 'ApiException($error): $message';

  /// User-visible text without appended [details] from [_composeMessage].
  String get userMessage {
    final firstLine = message.split('\n').first.trim();
    return firstLine.isEmpty ? 'Request failed' : firstLine;
  }
}
