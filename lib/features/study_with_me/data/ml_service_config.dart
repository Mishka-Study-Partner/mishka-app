import 'package:mishka_app/core/network/mishka_ai_model_urls.dart';

/// ML posture service (FastAPI WebSocket — see docs/CAMERA_WITH_MISHKA_ML_INTEGRATION.md).
abstract final class MlServiceConfig {
  MlServiceConfig._();

  /// Override at build time: `--dart-define=ML_SERVICE_BASE_URL=https://...`
  static const String baseUrl = String.fromEnvironment(
    'ML_SERVICE_BASE_URL',
    defaultValue: MishkaAiModelUrls.studyMonitorProductionBaseUrl,
  );

  /// Dev-only ngrok reference — not used unless you override [baseUrl] to this.
  static const String legacyNgrokBaseUrl =
      MishkaAiModelUrls.legacyNgrokBaseUrl;

  /// Local AI on port 8080 — override with `--dart-define=ML_SERVICE_BASE_URL=...`
  static const String localDevBaseUrl = MishkaAiModelUrls.localDevBaseUrl;

  static const String webSocketPath = '/ws/study-session';

  /// ~2 FPS — balance accuracy vs battery (ML recommends 5–10 FPS when feasible).
  static const Duration frameInterval = Duration(milliseconds: 500);

  /// Shown while Mishka calibrates to the user's posture before live analysis.
  static const Duration calibrationDuration = Duration(seconds: 5);

  static Uri get webSocketUri {
    final parsed = Uri.parse(baseUrl);
    final scheme = parsed.scheme == 'https' ? 'wss' : 'ws';
    return parsed.replace(
      scheme: scheme,
      path: webSocketPath,
      query: null,
      fragment: null,
    );
  }

  static Map<String, String> get connectionHeaders =>
      MishkaAiModelUrls.headersFor(baseUrl);
}
