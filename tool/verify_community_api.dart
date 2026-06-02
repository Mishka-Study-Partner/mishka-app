// ignore_for_file: avoid_print
/// Verifies Community API endpoints against the backend.
///
/// Usage:
///   TEST_EMAIL=you@example.com TEST_PASSWORD=secret dart run tool/verify_community_api.dart
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
    print('   OK');

    print('2. GET /communities…');
    final communities = await _get(client, '/communities', token);
    print('   HTTP ${communities.statusCode} items=${_listLength(communities.body)}');

    print('3. GET /user-communities…');
    final memberships = await _get(client, '/user-communities', token);
    print('   HTTP ${memberships.statusCode} items=${_listLength(memberships.body)}');

    final communityId = _firstCommunityId(communities.body) ??
        _firstCommunityId(memberships.body);
    if (communityId != null) {
      print('4. GET /communities/$communityId/channels…');
      final channels = await _get(
        client,
        '/communities/$communityId/channels',
        token,
      );
      print('   HTTP ${channels.statusCode} items=${_listLength(channels.body)}');

      print('5. GET /communities/$communityId/members…');
      final members = await _get(
        client,
        '/communities/$communityId/members',
        token,
      );
      print('   HTTP ${members.statusCode} items=${_listLength(members.body)}');
    } else {
      print('4–5. Skipped channel/member checks (no community id in lists).');
    }

    print('\nDone.');
  } finally {
    client.close(force: true);
  }
}

Future<String?> _login(HttpClient client, String email, String password) async {
  final res = await _post(client, '/auth/login', null, {
    'email': email,
    'password': password,
  });
  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = map['data'];
  if (data is Map) {
    return (data['accessToken'] ?? data['token'])?.toString();
  }
  return null;
}

Future<_HttpResult> _get(HttpClient client, String path, String token) async {
  final req = await client.getUrl(Uri.parse('$_base$path'));
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Accept', 'application/json');
  req.headers.set('ngrok-skip-browser-warning', 'true');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  return _HttpResult(res.statusCode, body);
}

Future<_HttpResult> _post(
  HttpClient client,
  String path,
  String? token,
  Map<String, dynamic> body,
) async {
  final req = await client.postUrl(Uri.parse('$_base$path'));
  if (token != null) req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Content-Type', 'application/json');
  req.headers.set('Accept', 'application/json');
  req.headers.set('ngrok-skip-browser-warning', 'true');
  req.write(jsonEncode(body));
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  return _HttpResult(res.statusCode, text);
}

int? _listLength(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is List) return data.length;
  } catch (_) {}
  return null;
}

String? _firstCommunityId(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! List || data.isEmpty) return null;
    final first = data.first;
    if (first is! Map) return null;
    final nested = first['community'];
    if (nested is Map && nested['id'] != null) return nested['id'].toString();
    if (first['communityId'] != null) return first['communityId'].toString();
    if (first['id'] != null) return first['id'].toString();
  } catch (_) {}
  return null;
}

class _HttpResult {
  _HttpResult(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
