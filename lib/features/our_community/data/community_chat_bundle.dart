import 'community_models.dart';

/// Single fetch result for group chat (community + members + messages).
class CommunityChatBundle {
  const CommunityChatBundle({
    required this.community,
    required this.members,
    required this.messages,
    required this.memberNamesByUserId,
    required this.memberRolesByUserId,
  });

  final CommunityModel community;
  final List<CommunityMemberModel> members;
  final List<CommunityChatMessage> messages;
  final Map<String, String> memberNamesByUserId;
  final Map<String, String> memberRolesByUserId;
}
