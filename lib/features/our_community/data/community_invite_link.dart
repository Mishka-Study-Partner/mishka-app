import 'dart:convert';

/// Parsed community invite from a universal link or custom scheme.
class CommunityInviteLink {
  const CommunityInviteLink({
    this.inviteToken,
    this.inviteCode,
    this.communityId,
  });

  final String? inviteToken;
  final String? inviteCode;
  final String? communityId;

  bool get isEmpty =>
      (inviteToken == null || inviteToken!.isEmpty) &&
      (inviteCode == null || inviteCode!.isEmpty) &&
      (communityId == null || communityId!.isEmpty);

  Map<String, dynamic> toJson() => {
        if (inviteToken != null && inviteToken!.isNotEmpty)
          'inviteToken': inviteToken,
        if (inviteCode != null && inviteCode!.isNotEmpty)
          'inviteCode': inviteCode,
        if (communityId != null && communityId!.isNotEmpty)
          'communityId': communityId,
      };

  String toJsonString() => jsonEncode(toJson());

  factory CommunityInviteLink.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const CommunityInviteLink();
    return CommunityInviteLink.fromJson(Map<String, dynamic>.from(decoded));
  }

  factory CommunityInviteLink.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key]?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    return CommunityInviteLink(
      inviteToken: read('inviteToken'),
      inviteCode: read('inviteCode'),
      communityId: read('communityId'),
    );
  }

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Supports mishkacommunity.com, Railway API links, and `mishka://` dev links.
  static CommunityInviteLink? tryParse(Uri uri) {
    if (uri.scheme == 'mishka') {
      return _fromQuery(uri.queryParameters);
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!_isSupportedWebHost(uri.host)) return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    if (segments.first == 'join' ||
        (segments.length >= 2 &&
            segments[0] == 'communities' &&
            segments[1] == 'join')) {
      return _fromQuery(uri.queryParameters);
    }

    if (segments.first == 'communities' && segments.length >= 2) {
      final id = segments[1];
      if (id != 'join' && _uuid.hasMatch(id)) {
        return CommunityInviteLink(communityId: id);
      }
    }

    return null;
  }

  static CommunityInviteLink? _fromQuery(Map<String, String> query) {
    final token = _firstNonEmpty([
      query['inviteToken'],
      query['token'],
    ]);
    final code = _firstNonEmpty([
      query['inviteCode'],
      query['code'],
    ]);
    final communityId = _firstNonEmpty([
      query['communityId'],
    ]);

    final link = CommunityInviteLink(
      inviteToken: token,
      inviteCode: code,
      communityId: communityId,
    );
    return link.isEmpty ? null : link;
  }

  static bool _isSupportedWebHost(String host) {
    final h = host.toLowerCase();
    return h == 'www.mishkacommunity.com' ||
        h == 'mishkacommunity.com' ||
        h.endsWith('.railway.app') ||
        h.contains('ngrok');
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
