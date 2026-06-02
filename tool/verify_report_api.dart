// ignore_for_file: avoid_print
/// Verifies Your Report APIs against production (bundle + legacy fallbacks).
///
/// Usage:
///   TEST_EMAIL=you@example.com TEST_PASSWORD=secret dart run tool/verify_report_api.dart
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
  var bundleReady = false;
  var legacyOk = true;

  try {
    print('1. Login…');
    final token = await _login(client, email, password);
    if (token == null) {
      print('FAIL: login did not return accessToken');
      exit(1);
    }
    print('   OK — token received\n');

    print('2. GET /reports/your-report?format=bundle&period=weekly…');
    final bundle = await _get(
      client,
      '/reports/your-report?format=bundle&period=weekly',
      token,
    );
    print('   HTTP ${bundle.statusCode} success=${_success(bundle.body)}');
    if (bundle.statusCode >= 200 && bundle.statusCode < 300 && _success(bundle.body)) {
      bundleReady = true;
      final keys = _bundleKeys(bundle.body);
      print('   bundle keys: ${keys.join(", ")}');
    } else {
      print('   (expected until backend deploys — Flutter uses legacy fallback)');
      if (bundle.body.length < 500) print('   body: ${bundle.body}');
    }

    print('\n3. Legacy study week (topLevelMode=all)…');
    final weekAll = await _get(
      client,
      '/study-with-mishka/reports/week?topLevelMode=all',
      token,
    );
    print('   HTTP ${weekAll.statusCode} success=${_success(weekAll.body)}');
    if (weekAll.statusCode < 200 || weekAll.statusCode >= 300) {
      legacyOk = false;
      print('   Trying dual-mode merge…');
      for (final mode in ['concentration', 'call_with_mishka']) {
        final r = await _get(
          client,
          '/study-with-mishka/reports/week?topLevelMode=$mode',
          token,
        );
        print('   $mode HTTP ${r.statusCode} success=${_success(r.body)}');
        if (r.statusCode < 200 || r.statusCode >= 300) legacyOk = false;
      }
    }

    print('\n4. GET /daily-streaks…');
    final streak = await _get(client, '/daily-streaks', token);
    print('   HTTP ${streak.statusCode} success=${_success(streak.body)}');
    if (streak.statusCode < 200 || streak.statusCode >= 300) legacyOk = false;

    print('\n5. GET /tasks…');
    final tasks = await _get(client, '/tasks', token);
    print('   HTTP ${tasks.statusCode} success=${_success(tasks.body)}');
    if (tasks.statusCode < 200 || tasks.statusCode >= 300) legacyOk = false;

    print('\n6. POST /reports/your-report/export (delivery=download)…');
    final export = await _post(
      client,
      '/reports/your-report/export',
      token,
      {
        'period': 'weekly',
        'locale': 'en',
        'delivery': 'download',
      },
    );
    print('   HTTP ${export.statusCode} success=${_success(export.body)}');
    final exportReady = export.statusCode >= 200 &&
        export.statusCode < 300 &&
        _success(export.body);
    if (!exportReady && export.body.length < 500) {
      print('   (expected until deploy — Flutter falls back to local PDF)');
      print('   body: ${export.body}');
    }

    print('\n--- Summary ---');
    print('Bundle API ready:     ${bundleReady ? "YES" : "NO (legacy fallback active)"}');
    print('Legacy APIs usable:   ${legacyOk ? "YES" : "NO — check auth/data"}');
    print('Server PDF export:    ${exportReady ? "YES" : "NO (local PDF fallback active)"}');

    if (legacyOk || bundleReady) {
      print('\nPASS — at least one report data path works.');
      exit(0);
    }
    print('\nFAIL — neither bundle nor legacy paths responded OK.');
    exit(1);
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

List<String> _bundleKeys(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is Map) return data.keys.map((k) => k.toString()).toList()..sort();
  } catch (_) {}
  return const [];
}

void _applyNgrokHeaders(HttpClientRequest req) {
  if (_base.contains('ngrok')) {
    req.headers.set('ngrok-skip-browser-warning', 'true');
  }
}
