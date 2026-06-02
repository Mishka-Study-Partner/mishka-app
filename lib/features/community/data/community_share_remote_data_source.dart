import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/community/data/models/joined_community_models.dart';

/// Loads communities the user joined and their shareable groups (channels).
class CommunityShareRemoteDataSource {
  CommunityShareRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<JoinedCommunity>> getJoinedCommunitiesForShare() async {
    final membershipsEnv = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.userCommunities,
      dataFromJson: _listOfMapsFromRaw,
    );
    final memberships = membershipsEnv.data ?? const [];

    final communities = <JoinedCommunity>[];
    final seenCommunityIds = <String>{};

    for (final membership in memberships) {
      final communityId = _communityIdFromRow(membership);
      if (communityId.isEmpty || seenCommunityIds.contains(communityId)) {
        continue;
      }
      seenCommunityIds.add(communityId);

      final meta = _communityMetaFromRow(membership, communityId);
      final groups = await _loadCommunityGroups(communityId);
      if (groups.isEmpty) continue;

      communities.add(
        JoinedCommunity(
          id: communityId,
          name: meta.name,
          imageUrl: meta.imageUrl,
          memberCount: meta.memberCount > 0
              ? meta.memberCount
              : groups.fold<int>(0, (sum, g) => sum + g.memberCount),
          groups: groups,
        ),
      );
    }

    if (communities.isNotEmpty) {
      return communities;
    }

    return _fallbackFromPublicCommunities();
  }

  Future<List<JoinedCommunity>> _fallbackFromPublicCommunities() async {
    final env = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.communities,
      dataFromJson: _listOfMapsFromRaw,
    );
    final rows = env.data ?? const [];
    final communities = <JoinedCommunity>[];

    for (final row in rows) {
      final communityId = _communityIdFromRow(row);
      if (communityId.isEmpty) continue;
      final meta = _communityMetaFromRow(row, communityId);
      final groups = await _loadCommunityGroups(communityId);
      if (groups.isEmpty) continue;
      communities.add(
        JoinedCommunity(
          id: communityId,
          name: meta.name,
          imageUrl: meta.imageUrl,
          memberCount: meta.memberCount,
          groups: groups,
        ),
      );
    }
    return communities;
  }

  Future<List<CommunityGroup>> _loadCommunityGroups(String communityId) async {
    final env = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.communityChannels(communityId),
      dataFromJson: _listOfMapsFromRaw,
    );
    final rows = env.data ?? const [];
    final parsed = rows.map((row) => _groupFromRow(row, communityId)).where(
          (group) => group.id.isNotEmpty,
        ).toList();

    final hasJoinedField = rows.any((r) => r.containsKey('joined'));
    if (hasJoinedField) {
      return parsed.where((g) => g.joined).toList();
    }
    return parsed;
  }

  _CommunityMeta _communityMetaFromRow(
    Map<String, dynamic> row,
    String communityId,
  ) {
    final nested = row['community'];
    final source = nested is Map
        ? Map<String, dynamic>.from(nested)
        : row;

    final name = (source['name'] ??
            source['title'] ??
            row['communityName'] ??
            row['name'] ??
            row['title'] ??
            'Community')
        .toString();

    final imageUrl = (source['imageUrl'] ??
            source['avatarUrl'] ??
            source['iconUrl'] ??
            row['imageUrl'])
        ?.toString();

    final memberCount = _parseInt(
      source['memberCount'] ??
          source['membersCount'] ??
          row['memberCount'] ??
          row['membersCount'],
    );

    return _CommunityMeta(
      name: name.isEmpty ? 'Community' : name,
      imageUrl: imageUrl?.isEmpty == true ? null : imageUrl,
      memberCount: memberCount,
    );
  }

  String _communityIdFromRow(Map<String, dynamic> row) {
    final nested = row['community'];
    if (nested is Map) {
      final id = (nested['id'] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
    for (final key in const ['communityId', 'id']) {
      final value = row[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  CommunityGroup _groupFromRow(Map<String, dynamic> row, String communityId) {
    final id = (row['id'] ?? row['channelId'] ?? '').toString();
    final name = (row['title'] ?? row['name'] ?? 'Group').toString();
    final imageUrl = (row['imageUrl'] ?? row['iconUrl'])?.toString();
    final memberCount = _parseInt(
      row['memberCount'] ?? row['membersCount'] ?? row['member_count'],
    );
    final joinedRaw = row['joined'];
    final joined = joinedRaw == null
        ? true
        : joinedRaw == true || joinedRaw.toString().toLowerCase() == 'true';

    return CommunityGroup(
      id: id,
      communityId: communityId,
      name: name.isEmpty ? 'Group' : name,
      imageUrl: imageUrl?.isEmpty == true ? null : imageUrl,
      memberCount: memberCount,
      joined: joined,
    );
  }

  int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _listOfMapsFromRaw(Object? raw) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class _CommunityMeta {
  const _CommunityMeta({
    required this.name,
    this.imageUrl,
    this.memberCount = 0,
  });

  final String name;
  final String? imageUrl;
  final int memberCount;
}
