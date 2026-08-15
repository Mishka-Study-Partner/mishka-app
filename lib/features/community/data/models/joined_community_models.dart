class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.communityId,
    required this.name,
    this.imageUrl,
    this.memberCount = 0,
    this.joined = true,
  });

  final String id;
  final String communityId;
  final String name;
  final String? imageUrl;
  final int memberCount;
  final bool joined;
}

class JoinedCommunity {
  const JoinedCommunity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.memberCount = 0,
    this.groups = const [],
  });

  final String id;
  final String name;
  final String? imageUrl;
  final int memberCount;
  final List<CommunityGroup> groups;

  int get groupCount => groups.length;
}

class ShareCommunitySelection {
  const ShareCommunitySelection({
    required this.groups,
    this.note,
  });

  final List<CommunityGroup> groups;
  final String? note;

  List<String> get channelIds => groups.map((g) => g.id).toList();

  CommunityGroup? get primaryGroup => groups.isEmpty ? null : groups.first;
}
