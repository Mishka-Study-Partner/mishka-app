// ignore_for_file: avoid_print
/// Verifies backend fixes from docs/BACKEND_COMMUNITY_API_REQUEST.md
///
/// Usage (from repo root):
///   TEST_EMAIL=you@example.com TEST_PASSWORD=secret ./tool/verify_community_backend_fixes.sh
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
    print('Set TEST_EMAIL and TEST_PASSWORD to run live API verification.');
    exit(1);
  }

  print('Base URL: $_base\n');
  final client = HttpClient();
  var failures = 0;

  try {
    print('── Login ──');
    final token = await _login(client, email, password);
    if (token == null) {
      print('FAIL: no accessToken');
      exit(1);
    }
    print('OK\n');

    print('── 1. GET /user-communities — isPinned / saved field ──');
    final membershipsRes = await _get(client, '/user-communities', token);
    final membershipRows = _dataList(membershipsRes.body);
    final pinFieldCheck = _checkMembershipPinFields(membershipRows);
    _printCheck(
      'Membership rows include isPinned or saved',
      pinFieldCheck.present,
      pinFieldCheck.detail,
    );
    if (!pinFieldCheck.present) failures++;

    final communitiesRes = await _get(client, '/communities', token);
    final communityRows = _dataList(communitiesRes.body);
    final publicId = _findByVisibility(communityRows, 'public');
    final privateId = _findByVisibility(communityRows, 'private');
    final anyId = _firstCommunityId(membershipRows) ??
        (communityRows.isNotEmpty
            ? communityRows.first['id']?.toString()
            : null);

    if (anyId == null || anyId.isEmpty) {
      print('SKIP pin round-trip: no community id');
    } else {
      print('\n── 1b. POST pin → GET user-communities round-trip ──');
      final pinRes = await _post(client, '/communities/$anyId/pin', token, {});
      _printCheck(
        'POST /communities/$anyId/pin',
        pinRes.statusCode == 200,
        'HTTP ${pinRes.statusCode}',
      );
      if (pinRes.statusCode != 200) failures++;

      final afterPin = await _get(client, '/user-communities', token);
      final pinnedRow = _membershipFor(afterPin.body, anyId);
      final isPinned = _readPinned(pinnedRow);
      _printCheck(
        'Pinned community has isPinned/saved true after POST /pin',
        isPinned == true,
        pinnedRow == null
            ? 'membership not found'
            : 'isPinned=$isPinned row=$pinnedRow',
      );
      if (isPinned != true) failures++;

      final unpinRes = await _delete(client, '/communities/$anyId/pin', token);
      _printCheck(
        'DELETE /communities/$anyId/pin',
        unpinRes.statusCode == 200,
        'HTTP ${unpinRes.statusCode}',
      );

      final afterUnpin = await _get(client, '/user-communities', token);
      final unpinnedRow = _membershipFor(afterUnpin.body, anyId);
      final isPinnedAfter = _readPinned(unpinnedRow);
      _printCheck(
        'isPinned/saved false after DELETE /pin',
        isPinnedAfter == false,
        'isPinned=$isPinnedAfter',
      );
      if (isPinnedAfter != false) failures++;
    }

    if (publicId != null && publicId.isNotEmpty) {
      print('\n── 2. GET /communities/{id}/invite — public community ──');
      final inviteRes =
          await _get(client, '/communities/$publicId/invite', token);
      final inviteData = _dataMap(inviteRes.body);
      _printCheck(
        'GET invite returns 200 for public community',
        inviteRes.statusCode == 200,
        'HTTP ${inviteRes.statusCode} error=${_envelopeError(inviteRes.body)}',
      );
      if (inviteRes.statusCode != 200) failures++;

      if (inviteData != null) {
        final shareUrl =
            (inviteData['shareUrl'] ?? inviteData['shareLink'] ?? '').toString();
        final code = (inviteData['inviteCode'] ?? '').toString();
        final supported = inviteData['supported'];
        _printCheck(
          'Invite payload useful',
          shareUrl.isNotEmpty ||
              code.isNotEmpty ||
              supported == false,
          'shareUrl=${shareUrl.isEmpty ? '(empty)' : shareUrl} inviteCode=$code supported=$supported',
        );
      }
    } else {
      print('\n── 2. SKIP public invite (no public community in list) ──');
    }

    final msgCommunityId = publicId ?? privateId ?? anyId;
    if (msgCommunityId != null && msgCommunityId.isNotEmpty) {
      print('\n── 3. GET messages — senderDisplay / senderRole ──');
      final channelsRes =
          await _get(client, '/communities/$msgCommunityId/channels', token);
      final channels = _dataList(channelsRes.body);
      if (channels.isEmpty) {
        print('SKIP messages: no channels');
      } else {
        final channelId = (channels.first['id'] ?? '').toString();
        final msgRes = await _get(
          client,
          '/communities/$msgCommunityId/channels/$channelId/messages',
          token,
        );
        final messages = _dataList(msgRes.body);
        _printCheck(
          'GET messages returns 200',
          msgRes.statusCode == 200,
          'HTTP ${msgRes.statusCode} count=${messages.length}',
        );

        if (messages.isEmpty) {
          print('INFO: no messages to inspect sender fields');
        } else {
          final withDisplay = messages
              .where((m) => (m['senderDisplay'] ?? '').toString().isNotEmpty)
              .length;
          final withRole = messages
              .where((m) => (m['senderRole'] ?? '').toString().isNotEmpty)
              .length;
          _printCheck(
            'Messages include senderDisplay ($withDisplay/${messages.length})',
            withDisplay > 0,
            'first senderDisplay=${messages.first['senderDisplay']}',
          );
          _printCheck(
            'Messages include senderRole ($withRole/${messages.length})',
            withRole > 0,
            'first senderRole=${messages.first['senderRole']}',
          );
          if (withDisplay == 0) failures++;
          if (withRole == 0) failures++;
        }
      }
    }

    if (anyId != null && anyId.isNotEmpty) {
      print('\n── 4. POST /communities/{id}/invite — email body ──');
      final invitePost = await _post(
        client,
        '/communities/$anyId/invite',
        token,
        {
          'email':
              'flutter-verify-${DateTime.now().millisecondsSinceEpoch}@example.com',
        },
      );
      final err = _envelopeError(invitePost.body);
      final ok = invitePost.statusCode == 200 || invitePost.statusCode == 201;
      final expectedNotFound = invitePost.statusCode == 404 &&
          err == 'INVITE_USER_NOT_FOUND';
      _printCheck(
        'POST invite with email (unregistered → INVITE_USER_NOT_FOUND)',
        ok || expectedNotFound,
        'HTTP ${invitePost.statusCode} error=$err ${_envelopeMessage(invitePost.body)}',
      );
      if (!ok && !expectedNotFound) failures++;

      print('\n── 4c. POST invite — self-invite (own email) ──');
      final selfInvite = await _post(
        client,
        '/communities/$anyId/invite',
        token,
        {'email': email},
      );
      final selfErr = _envelopeError(selfInvite.body);
      _printCheck(
        'Self-invite returns INVITE_SELF_NOT_ALLOWED',
        selfErr == 'INVITE_SELF_NOT_ALLOWED',
        'HTTP ${selfInvite.statusCode} error=$selfErr ${_envelopeMessage(selfInvite.body)}',
      );
      if (selfErr != 'INVITE_SELF_NOT_ALLOWED') failures++;
    }

    print('\n══════════════════════════════════════');
    if (failures == 0) {
      print('All checks passed.');
      exit(0);
    } else {
      print('$failures check(s) FAILED.');
      exit(1);
    }
  } finally {
    client.close(force: true);
  }
}

void _printCheck(String label, bool pass, String detail) {
  print('${pass ? 'PASS' : 'FAIL'}: $label');
  if (detail.isNotEmpty) print('      $detail');
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

Future<_HttpResult> _delete(
  HttpClient client,
  String path,
  String? token,
) async {
  final req = await client.deleteUrl(Uri.parse('$_base$path'));
  if (token != null) req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Accept', 'application/json');
  req.headers.set('ngrok-skip-browser-warning', 'true');
  final res = await req.close();
  final text = await res.transform(utf8.decoder).join();
  return _HttpResult(res.statusCode, text);
}

List<Map<String, dynamic>> _dataList(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  } catch (_) {
    return [];
  }
}

Map<String, dynamic>? _dataMap(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
  } catch (_) {}
  return null;
}

String? _envelopeError(String body) {
  try {
    return (jsonDecode(body) as Map)['error']?.toString();
  } catch (_) {
    return null;
  }
}

String? _envelopeMessage(String body) {
  try {
    return (jsonDecode(body) as Map)['message']?.toString();
  } catch (_) {
    return null;
  }
}

({bool present, String detail}) _checkMembershipPinFields(
  List<Map<String, dynamic>> rows,
) {
  if (rows.isEmpty) {
    return (present: false, detail: 'no memberships');
  }
  final keys = rows.first.keys.map((k) => k.toString()).toList();
  final hasField = rows.any(
    (r) =>
        r.containsKey('isPinned') ||
        r.containsKey('pinned') ||
        r.containsKey('saved') ||
        r.containsKey('isSaved'),
  );
  return (
    present: hasField,
    detail: 'sample keys: ${keys.join(', ')}',
  );
}

bool? _readPinned(Map<String, dynamic>? row) {
  if (row == null) return null;
  if (row.containsKey('isPinned')) return row['isPinned'] == true;
  if (row.containsKey('pinned')) return row['pinned'] == true;
  if (row.containsKey('saved')) return row['saved'] == true;
  if (row.containsKey('isSaved')) return row['isSaved'] == true;
  return null;
}

Map<String, dynamic>? _membershipFor(String body, String communityId) {
  for (final row in _dataList(body)) {
    final id = (row['communityId'] ?? '').toString();
    if (id == communityId) return row;
    final nested = row['community'];
    if (nested is Map && nested['id']?.toString() == communityId) return row;
  }
  return null;
}

String? _firstCommunityId(List<Map<String, dynamic>> rows) {
  for (final row in rows) {
    final id = (row['communityId'] ?? '').toString();
    if (id.isNotEmpty) return id;
  }
  return null;
}

String? _findByVisibility(List<Map<String, dynamic>> rows, String visibility) {
  for (final row in rows) {
    final vis = (row['visibility'] ?? '').toString().toLowerCase();
    if (vis.contains(visibility)) return row['id']?.toString();
  }
  return null;
}

class _HttpResult {
  _HttpResult(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
