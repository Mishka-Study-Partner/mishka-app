// ignore_for_file: avoid_print
/// Connectivity check for Mishka AI (Chat with Mishka) — no token usage.
///
/// Does NOT call /upload, /chat, or /generate-tools (those consume model tokens).
/// Use the app manually for one PDF + one tool after this passes.
///
/// Usage (run file directly — not `dart run` from Flutter root):
///   dart tool/verify_chat_ai_api.dart
///   AI_BASE_URL=https://your-host dart tool/verify_chat_ai_api.dart
import 'dart:convert';
import 'dart:io';

const _base = String.fromEnvironment(
  'AI_BASE_URL',
  defaultValue: 'https://mishka-ai-model-production-c459.up.railway.app',
);

const _expectedPaths = ['/upload', '/chat', '/generate-tools'];

Future<void> main() async {
  var ok = true;

  print('=== Chat AI wiring (local) ===\n');
  ok = _checkLocalWiring() && ok;

  print('\n=== Chat AI connectivity (no inference) ===');
  print('Base URL: $_base\n');

  final client = HttpClient();
  try {
    print('1. GET / …');
    final root = await _get(client, '/');
    final rootOk = root.statusCode >= 200 && root.statusCode < 400;
    print('   HTTP ${root.statusCode} ${rootOk ? "OK" : "FAIL"}');
    if (!rootOk) {
      print('   body: ${_preview(root.body)}');
      ok = false;
    } else {
      print('   ${_preview(root.body, max: 120)}');
    }

    print('\n2. GET /openapi.json …');
    final openapi = await _get(client, '/openapi.json');
    final openapiOk = openapi.statusCode >= 200 && openapi.statusCode < 300;
    print('   HTTP ${openapi.statusCode} ${openapiOk ? "OK" : "FAIL"}');
    if (!openapiOk) {
      print('   body: ${_preview(openapi.body)}');
      ok = false;
    } else {
      ok = _checkOpenApiPaths(openapi.body) && ok;
    }

    if (_base.contains('ngrok')) {
      print('\n3. ngrok header check (GET / without skip header) …');
      final bare = await _get(client, '/', ngrokSkip: false);
      final withSkip = await _get(client, '/', ngrokSkip: true);
      print('   without header: HTTP ${bare.statusCode}');
      print('   with ngrok-skip-browser-warning: HTTP ${withSkip.statusCode}');
      if (withSkip.statusCode >= 200 &&
          withSkip.statusCode < 400 &&
          bare.statusCode != withSkip.statusCode) {
        print('   OK — app must send ngrok-skip-browser-warning (already wired in AiServiceConfig)');
      } else if (withSkip.statusCode >= 200 && withSkip.statusCode < 400) {
        print('   OK — reachable with ngrok header');
      } else {
        ok = false;
      }
    }

    print(ok
        ? '\nPASS — service reachable; wiring looks good. Test one PDF + one tool in the app.'
        : '\nFAIL — fix connectivity or wiring before manual test.');
    exit(ok ? 0 : 1);
  } finally {
    client.close();
  }
}

bool _checkLocalWiring() {
  var ok = true;
  const configPath = 'lib/features/chat_with_mishka/data/ai_service_config.dart';
  const urlsPath = 'lib/core/network/mishka_ai_model_urls.dart';
  const servicePath =
      'lib/features/chat_with_mishka/data/service/mishka_ai_service.dart';

  for (final path in [configPath, urlsPath, servicePath]) {
    final exists = File(path).existsSync();
    print('${exists ? "OK" : "FAIL"} — $path ${exists ? "exists" : "missing"}');
    ok = exists && ok;
  }

  if (File(configPath).existsSync()) {
    final config = File(configPath).readAsStringSync();
    if (config.contains('mishka-ai-model-production-c459.up.railway.app')) {
      print('OK — production AI base URL points at Railway');
    } else {
      print('WARN — ai_service_config.dart does not reference Railway AI host');
    }
    if (config.contains('MishkaAiModelUrls')) {
      print('OK — AiServiceConfig uses shared MishkaAiModelUrls');
    } else {
      print('FAIL — AiServiceConfig should use MishkaAiModelUrls');
      ok = false;
    }
  }

  if (File(urlsPath).existsSync()) {
    final urls = File(urlsPath).readAsStringSync();
    if (urls.contains('legacyNgrokBaseUrl')) {
      print('OK — legacy ngrok URL kept for dev reference only');
    }
    if (urls.contains('ngrok-skip-browser-warning')) {
      print('OK — ngrok header helper defined for dev tunnels');
    }
  }

  if (File(servicePath).existsSync()) {
    final service = File(servicePath).readAsStringSync();
    if (service.contains('AiServiceConfig')) {
      print('OK — MishkaAiService uses AiServiceConfig');
    } else {
      print('FAIL — MishkaAiService does not import AiServiceConfig');
      ok = false;
    }
    if (service.contains('_headers') || service.contains('AiServiceConfig.headers')) {
      print('OK — MishkaAiService applies config headers on requests');
    } else {
      print('FAIL — MishkaAiService may not send connection headers');
      ok = false;
    }
  }

  return ok;
}

bool _checkOpenApiPaths(String body) {
  try {
    final doc = jsonDecode(body) as Map<String, dynamic>;
    final paths = doc['paths'];
    if (paths is! Map) {
      print('   FAIL — openapi.json has no paths object');
      return false;
    }
    var ok = true;
    for (final path in _expectedPaths) {
      final present = paths.containsKey(path);
      print('   ${present ? "OK" : "FAIL"} — path $path in OpenAPI');
      ok = present && ok;
    }
    return ok;
  } catch (e) {
    print('   FAIL — could not parse openapi.json ($e)');
    return false;
  }
}

Future<({int statusCode, String body})> _get(
  HttpClient client,
  String path, {
  bool ngrokSkip = true,
}) async {
  final req = await client.getUrl(Uri.parse('$_base$path'));
  req.headers.set('Accept', 'application/json');
  if (ngrokSkip && _base.contains('ngrok')) {
    req.headers.set('ngrok-skip-browser-warning', 'true');
  }
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  return (statusCode: res.statusCode, body: body);
}

String _preview(String text, {int max = 500}) {
  final trimmed = text.replaceAll('\n', ' ').trim();
  if (trimmed.length <= max) return trimmed;
  return '${trimmed.substring(0, max)}…';
}
