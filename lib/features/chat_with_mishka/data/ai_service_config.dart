import 'package:mishka_app/core/network/mishka_ai_model_urls.dart';

/// Mishka AI Study Partner REST API (Chat with Mishka).
///
/// Same host as Camera ML when using defaults — different paths:
/// - `POST /upload`, `/chat`, `/generate-tools` (this feature)
/// - `WS /ws/study-session` (posture monitor)
abstract final class AiServiceConfig {
  AiServiceConfig._();

  /// Override: `--dart-define=AI_BASE_URL=https://...`
  static const String baseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: MishkaAiModelUrls.productionBaseUrl,
  );

  /// Dev-only ngrok reference — not used unless you override [baseUrl] to this.
  static const String legacyNgrokBaseUrl =
      MishkaAiModelUrls.legacyNgrokBaseUrl;

  /// Local AI on port 8080 — override with `--dart-define=AI_BASE_URL=...`
  static const String localDevBaseUrl = MishkaAiModelUrls.localDevBaseUrl;

  static Map<String, String> get headers =>
      MishkaAiModelUrls.headersFor(baseUrl);

  static const Duration uploadTimeout = Duration(minutes: 3);

  static const Duration chatTimeout = Duration(seconds: 90);

  static const Duration generateToolsTimeout = Duration(minutes: 2);
}
