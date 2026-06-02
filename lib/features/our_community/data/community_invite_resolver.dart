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
    final url = api.shareUrl?.isNotEmpty == true
        ? api.shareUrl!
        : buildShareUrl(
            community.id,
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
