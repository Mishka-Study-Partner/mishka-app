// ignore_for_file: avoid_print
/// Checks backend self-invite error on POST /communities/{id}/invite.
///
/// Usage: ./tool/verify_self_invite_error.sh
import 'dart:convert';
import 'dart:io';

const _base = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://fleshy-lemon-persevere.ngrok-free.dev',
);

void main() async {
  final email = Platform.environment['TEST_EMAIL']?.trim();
  final password = Platform.environment['TEST_PASSWORD'];

  if (email == null || email.isEmpty || password == null || password.isEmpty) {
    print('Set TEST_EMAIL and TEST_PASSWORD.');
    exit(1);
  }

  final client = HttpClient();
  try {
    print('Base: $_base\n');
    final login = await _post(client, '/auth/login', null, {
      'email': email,
      'password': password,
    });
    final loginMap = jsonDecode(login.body) as Map<String, dynamic>;
    final data = loginMap['data'];
    if (data is! Map) {
      print('Login failed: ${login.body}');
      exit(1);
    }
    final token = (data['accessToken'] ?? data['token'])?.toString();
    final user = data['user'] is Map ? data['user'] as Map : data;
    final userEmail = (user['email'] ?? email).toString();
    final username = (user['username'] ?? '').toString();

    final communities = await _get(client, '/communities', token!);
    final rows = _dataList(communities.body);
    if (rows.isEmpty) {
      print('No communities to test.');
      exit(1);
    }
    final communityId = rows.first['id'].toString();

    for (final label in ['email', 'username']) {
      final body = label == 'email'
          ? {'email': userEmail}
          : {'username': username};
      if (label == 'username' && username.isEmpty) continue;

      final res = await _post(
        client,
        '/communities/$communityId/invite',
        token,
        body,
      );
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final err = map['error']?.toString() ?? '';
      final msg = map['message']?.toString() ?? '';

      print('── Self-invite via $label ($body) ──');
      print('HTTP ${res.statusCode}');
      print('error: $err');
      print('message: $msg');

      final clear = err == 'INVITE_SELF_NOT_ALLOWED' ||
          msg.toLowerCase().contains('cannot invite yourself');
      print(clear ? 'OK: clear self-invite error' : 'WARN: unexpected response');
      print('');
    }
  } finally {
    client.close(force: true);
  }
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

Future<_HttpResult> _get(HttpClient client, String path, String token) async {
  final req = await client.getUrl(Uri.parse('$_base$path'));
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Accept', 'application/json');
  req.headers.set('ngrok-skip-browser-warning', 'true');
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  return _HttpResult(res.statusCode, text);
}

List<Map<String, dynamic>> _dataList(String body) {
  final map = jsonDecode(body) as Map<String, dynamic>;
  final data = map['data'];
  if (data is List) {
    return data.cast<Map<String, dynamic>>();
  }
  return const [];
}

class _HttpResult {
  _HttpResult(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
