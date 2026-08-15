import 'package:mishka_app/core/network/api_endpoints.dart';

import 'community_models.dart';

/// Builds share URLs and fallbacks when `GET /communities/:id/invite` is unavailable
/// (e.g. public communities return validation errors).
abstract final class CommunityInviteResolver {
  static const defaultWebOrigin = 'https://www.mishkacommunity.com';

  static CommunityInviteInfo merge(
    CommunityInviteInfo api,
    CommunityModel community,
  ) {
    final code = api.inviteCode ?? community.inviteCode;
    final token = api.inviteToken ?? community.inviteToken;
    final url = sanitizeShareUrl(
      api.shareUrl,
      communityId: community.id,
      inviteCode: code,
      inviteToken: token,
    );
    return CommunityInviteInfo(
      inviteCode: code,
      inviteToken: token,
      shareUrl: url,
      supported: api.supported,
      visibility:
          api.visibility ?? (community.isPublic ? 'public' : 'private'),
      hint: api.hint,
    );
  }

  static CommunityInviteInfo sanitizeInvite(
    CommunityInviteInfo info, {
    required String communityId,
  }) {
    final url = sanitizeShareUrl(
      info.shareUrl,
      communityId: communityId,
      inviteCode: info.inviteCode,
      inviteToken: info.inviteToken,
    );
    if (url == info.shareUrl) return info;
    return CommunityInviteInfo(
      inviteCode: info.inviteCode,
      inviteToken: info.inviteToken,
      shareUrl: url,
      supported: info.supported,
      visibility: info.visibility,
      hint: info.hint,
    );
  }

  /// Rewrites Railway/API join URLs so browsers do not hit authenticated routes.
  static String sanitizeShareUrl(
    String? shareUrl, {
    required String communityId,
    String? inviteCode,
    String? inviteToken,
  }) {
    if (shareUrl == null || shareUrl.isEmpty) {
      return buildShareUrl(
        communityId,
        inviteCode: inviteCode,
        inviteToken: inviteToken,
      );
    }

    final uri = Uri.tryParse(shareUrl);
    if (uri == null) return shareUrl;

    final token = _firstNonEmpty([
      inviteToken,
      uri.queryParameters['inviteToken'],
      uri.queryParameters['token'],
    ]);
    final code = _firstNonEmpty([
      inviteCode,
      uri.queryParameters['inviteCode'],
      uri.queryParameters['code'],
    ]);
    final targetCommunityId = _firstNonEmpty([
      uri.queryParameters['communityId'],
      communityId,
    ])!;

    if (_isApiHost(uri.host)) {
      if (token != null) {
        return buildShareUrl(targetCommunityId, inviteToken: token);
      }
      if (code != null) {
        return buildShareUrl(targetCommunityId, inviteCode: code);
      }
      return buildPublicCommunityUrl(targetCommunityId);
    }

    return shareUrl;
  }

  static bool _isApiHost(String host) {
    if (host.isEmpty) return false;
    final apiHost = Uri.tryParse(ApiEndpoints.baseUrl)?.host;
    if (apiHost != null && host == apiHost) return true;
    return host.contains('railway.app') || host.contains('ngrok');
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static CommunityInviteInfo fromCommunity(CommunityModel community) {
    final code = community.inviteCode;
    final token = community.inviteToken;
    if ((code?.isNotEmpty ?? false) || (token?.isNotEmpty ?? false)) {
      return CommunityInviteInfo(
        inviteCode: code,
        inviteToken: token,
        shareUrl: buildShareUrl(
          community.id,
          inviteCode: code,
          inviteToken: token,
        ),
      );
    }
    if (community.isPublic) {
      return CommunityInviteInfo(
        shareUrl: buildPublicCommunityUrl(community.id),
        inviteCode: community.id,
      );
    }
    return CommunityInviteInfo(shareUrl: buildPublicCommunityUrl(community.id));
  }

  static String buildPublicCommunityUrl(String communityId) =>
      '$defaultWebOrigin/communities/$communityId';

  static String buildShareUrl(
    String communityId, {
    String? inviteCode,
    String? inviteToken,
  }) {
    if (inviteToken != null && inviteToken.isNotEmpty) {
      return '$defaultWebOrigin/join?token=${Uri.encodeComponent(inviteToken)}';
    }
    if (inviteCode != null && inviteCode.isNotEmpty) {
      return '$defaultWebOrigin/join?code=${Uri.encodeComponent(inviteCode)}';
    }
    return buildPublicCommunityUrl(communityId);
  }
}
