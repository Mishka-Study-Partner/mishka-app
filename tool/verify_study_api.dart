// ignore_for_file: avoid_print
/// Verifies Study With Mishka session start against production.
///
/// Usage:
///   TEST_EMAIL=you@example.com TEST_PASSWORD=secret dart run tool/verify_study_api.dart
import 'dart:convert';
import 'dart:io';

const _base = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://fleshy-lemon-persevere.ngrok-free.dev',
);

Future<void> main() async {
  final email = Platform.environment['TEST_EMAIL']?.trim();
  final password = Platform.environment['TEST_PASSWORD'];

  if (email == null ||
      email.isEmpty ||
      password == null ||
      password.isEmpty) {
    print('Set TEST_EMAIL and TEST_PASSWORD to run live API verification.');
    exit(1);
  }

  final client = HttpClient();
  try {
    print('1. Login…');
    final token = await _login(client, email, password);
    if (token == null) {
      print('FAIL: login did not return accessToken');
      exit(1);
    }
    print('   OK — token received');

    print('2. GET /study-with-mishka/catalog…');
    final catalog = await _get(client, '/study-with-mishka/catalog', token);
    print('   HTTP ${catalog.statusCode} success=${_success(catalog.body)}');

    print('3. POST /study-with-mishka/sessions/start (call_with_mishka)…');
    final callStart = await _post(
      client,
      '/study-with-mishka/sessions/start',
      token,
      {
        'topLevelMode': 'call_with_mishka',
        'platform': Platform.isMacOS || Platform.isLinux ? 'android' : 'ios',
      },
    );
    final callId = _sessionId(callStart.body);
    print('   HTTP ${callStart.statusCode} sessionId=${callId ?? "—"}');
    if (callStart.statusCode != 201 && callStart.statusCode != 200) {
      print('   body: ${callStart.body}');
    }

    if (callId != null) {
      print('4. POST …/sessions/$callId/end…');
      final end = await _post(
        client,
        '/study-with-mishka/sessions/$callId/end',
        token,
        {'outcome': 'completed'},
      );
      print('   HTTP ${end.statusCode} success=${_success(end.body)}');
    }

    print('5. POST /study-with-mishka/sessions/start (concentration)…');
    final concStart = await _post(
      client,
      '/study-with-mishka/sessions/start',
      token,
      {
        'topLevelMode': 'concentration',
        'concentrationPreset': 'classic_pomodoro',
        'platform': 'ios',
      },
    );
    final concId = _sessionId(concStart.body);
    print('   HTTP ${concStart.statusCode} sessionId=${concId ?? "—"}');
    if (concStart.statusCode != 201 && concStart.statusCode != 200) {
      print('   body: ${concStart.body}');
    }

    if (concId != null) {
      await _post(
        client,
        '/study-with-mishka/sessions/$concId/end',
        token,
        {'outcome': 'completed'},
      );
    }

    final ok = (callStart.statusCode == 201 || callStart.statusCode == 200) &&
        callId != null &&
        (concStart.statusCode == 201 || concStart.statusCode == 200) &&
        concId != null;

    print(ok ? '\nPASS — session start works.' : '\nFAIL — see HTTP codes above.');
    exit(ok ? 0 : 1);
  } finally {
    client.close();
  }
}

Future<String?> _login(HttpClient client, String email, String password) async {
  final res = await _post(client, '/auth/login', null, {
    'email': email,
    'password': password,
  });
  if (res.statusCode < 200 || res.statusCode >= 300) {
    print('   login body: ${res.body}');
    return null;
  }
  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = map['data'];
  if (data is Map) {
    return (data['accessToken'] ?? data['token'])?.toString();
  }
  return null;
}

Future<({int statusCode, String body})> _get(
  HttpClient client,
  String path,
  String token,
) async {
  final req = await client.getUrl(Uri.parse('$_base$path'));
  req.headers.set('Accept', 'application/json');
  _applyNgrokHeaders(req);
  req.headers.set('Authorization', 'Bearer $token');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  return (statusCode: res.statusCode, body: body);
}

Future<({int statusCode, String body})> _post(
  HttpClient client,
  String path,
  String? token,
  Map<String, dynamic> data,
) async {
  final req = await client.postUrl(Uri.parse('$_base$path'));
  req.headers.set('Content-Type', 'application/json');
  req.headers.set('Accept', 'application/json');
  _applyNgrokHeaders(req);
  if (token != null) req.headers.set('Authorization', 'Bearer $token');
  req.write(jsonEncode(data));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  return (statusCode: res.statusCode, body: body);
}

bool _success(String body) {
  try {
    return (jsonDecode(body) as Map)['success'] == true;
  } catch (_) {
    return false;
  }
}

String? _sessionId(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is Map) {
      final id = data['id'] ?? data['sessionId'];
      if (id != null && id.toString().isNotEmpty) return id.toString();
    }
  } catch (_) {}
  return null;
}

void _applyNgrokHeaders(HttpClientRequest req) {
  if (_base.contains('ngrok')) {
    req.headers.set('ngrok-skip-browser-warning', 'true');
  }
}
