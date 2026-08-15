import 'package:flutter/foundation.dart';

import 'package:mishka_app/features/chat_with_mishka/data/ai_response_helpers.dart';

/// Prints the full AI error to the Flutter run terminal (debug console).
void logAiServiceError({
  required String operation,
  required Object error,
  StackTrace? stackTrace,
  String? baseUrl,
  String? url,
  String? userFacingMessage,
}) {
  debugPrint('');
  debugPrint('═══════════════════════════════════════');
  debugPrint('🤖 AI ERROR — $operation');
  if (baseUrl != null) debugPrint('   baseUrl: $baseUrl');
  if (url != null) debugPrint('   url: $url');
  debugPrint('   exception: $error');
  if (error is AiServiceException) {
    final detail = error.detail;
    if (detail != null && detail.isNotEmpty) {
      debugPrint('   detail: $detail');
    }
  }
  if (userFacingMessage != null && userFacingMessage.isNotEmpty) {
    debugPrint('   shownInUi: $userFacingMessage');
  }
  if (stackTrace != null) {
    debugPrint('   stackTrace:');
    debugPrint('$stackTrace');
  }
  debugPrint('═══════════════════════════════════════');
  debugPrint('');
}
