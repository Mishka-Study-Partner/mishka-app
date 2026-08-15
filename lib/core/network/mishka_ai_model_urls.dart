/// Mishka AI model host URLs (Chat upload/tools + Camera ML WebSocket).
abstract final class MishkaAiModelUrls {
  MishkaAiModelUrls._();

  /// Production Railway deployment for Chat With Mishka (REST tools / upload).
  ///
  /// Use this exact host **without** `:8080`. Railway maps public HTTPS (443) to the
  /// container's internal port (often 8080 via `$PORT`). Adding `:8080` to this URL
  /// will not work from the app or browser.
  static const productionBaseUrl =
      'https://mishka-ai-model-production-c459.up.railway.app';

  /// Production Railway deployment for Camera With Mishka posture ML (WebSocket).
  static const studyMonitorProductionBaseUrl =
      'https://study-monitor-model-production.up.railway.app';

  /// Local FastAPI dev server (listens on port 8080).
  /// `--dart-define=AI_BASE_URL=http://127.0.0.1:8080` (simulator: use host machine IP on device).
  static const localDevBaseUrl = 'http://127.0.0.1:8080';

  /// Legacy ngrok tunnel — temporary dev fallback only; may be offline or
  /// require `ngrok-skip-browser-warning`. Use `--dart-define=AI_BASE_URL=...`
  /// pointing here when testing against a local/ngrok AI server.
  static const legacyNgrokBaseUrl =
      'https://stanley-unmemorable-niftily.ngrok-free.dev';

  static bool isNgrokHost(String url) => url.contains('ngrok');

  static Map<String, String> headersFor(String url) {
    if (!isNgrokHost(url)) return const {};
    return const {'ngrok-skip-browser-warning': 'true'};
  }
}
