// ignore_for_file: avoid_print
/// Verifies Your Report bundle + export APIs (same contract as the Flutter app).
///
/// Usage:
///   TEST_EMAIL=you@example.com TEST_PASSWORD=secret dart run tool/verify_report_api.dart
import 'dart:convert';
import 'dart:io';

const _base = String.fromEnvironment(
  'API_BASE_URL',
    defaultValue: 'https://mishka-backend-production-3f6f.up.railway.app',
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
  final anchor = _todayAnchor();

  try {
    print('1. Login…');
    final token = await _login(client, email, password);
    if (token == null) {
      print('FAIL: login did not return accessToken');
      exit(1);
    }
    print('   OK — token received\n');

    print(
      '2. GET /reports/your-report?format=bundle&period=weekly&anchorDate=$anchor…',
    );
    final bundle = await _get(
      client,
      '/reports/your-report?format=bundle&period=weekly&anchorDate=$anchor&locale=en',
      token,
    );
    print('   HTTP ${bundle.statusCode} success=${_success(bundle.body)}');
    final bundleReady = bundle.statusCode >= 200 &&
        bundle.statusCode < 300 &&
        _success(bundle.body);
    if (bundleReady) {
      final keys = _bundleKeys(bundle.body);
      print('   bundle keys: ${keys.join(", ")}');
      final rings = _aiRingKeys(bundle.body);
      if (rings.isNotEmpty) print('   aiTools.rings: ${rings.join(", ")}');
    } else {
      if (bundle.body.length < 800) print('   body: ${bundle.body}');
    }

    print('\n3. POST /reports/your-report/export (delivery=download)…');
    final export = await _post(
      client,
      '/reports/your-report/export',
      token,
      {
        'period': 'weekly',
        'anchorDate': anchor,
        'locale': 'en',
        'delivery': 'download',
        'emailRecipient': 'account',
      },
    );
    print('   HTTP ${export.statusCode} success=${_success(export.body)}');
    final exportReady = export.statusCode >= 200 &&
        export.statusCode < 300 &&
        _success(export.body);
    if (!exportReady && export.body.length < 800) {
      print('   body: ${export.body}');
    }

    print('\n--- Summary ---');
    print('Bundle API ready:  ${bundleReady ? "YES" : "NO"}');
    print('Server PDF export: ${exportReady ? "YES" : "NO"}');

    if (bundleReady && exportReady) {
      print('\nPASS — bundle and export match Flutter integration.');
      exit(0);
    }
    print('\nFAIL — fix backend or query params before shipping Your Report.');
    exit(1);
  } finally {
    client.close();
  }
}

String _todayAnchor() {
  final now = DateTime.now().toUtc();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
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

List<String> _aiRingKeys(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! Map) return const [];
    final ai = data['aiTools'];
    if (ai is! Map) return const [];
    final rings = ai['rings'];
    if (rings is! List) return const [];
    return rings
        .whereType<Map>()
        .map((r) => (r['key'] ?? '').toString())
        .where((k) => k.isNotEmpty)
        .toList();
  } catch (_) {}
  return const [];
}

void _applyNgrokHeaders(HttpClientRequest req) {
  if (_base.contains('ngrok')) {
    req.headers.set('ngrok-skip-browser-warning', 'true');
  }
}
