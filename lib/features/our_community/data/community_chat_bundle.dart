import 'community_models.dart';

/// Messages + optional community refresh for group chat (no members fetch).
class CommunityChatBundle {
  const CommunityChatBundle({
    required this.community,
    required this.messages,
    this.members = const [],
    this.memberNamesByUserId = const {},
    this.memberRolesByUserId = const {},
  });

  final CommunityModel community;
  final List<CommunityMemberModel> members;
  final List<CommunityChatMessage> messages;
  final Map<String, String> memberNamesByUserId;
  final Map<String, String> memberRolesByUserId;
}
