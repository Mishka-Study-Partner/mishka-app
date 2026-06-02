import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';

import 'community_discover_models.dart';
import 'community_json_helpers.dart';
import 'community_models.dart';

class CommunityRemoteDataSource {
  CommunityRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final env = await _api.get<List<Map<String, dynamic>>>(
      path,
      dataFromJson: listOfMapsFromRaw,
    );
    return env.data ?? const [];
  }

  Future<Map<String, dynamic>?> _fetchMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final env = await _api.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      dataFromJson: mapFromRawOrEmpty,
    );
    return env.data;
  }

  Future<List<Map<String, dynamic>>> fetchMemberships() =>
      _fetchList(ApiEndpoints.userCommunities);

  Future<List<Map<String, dynamic>>> fetchCommunities() =>
      _fetchList(ApiEndpoints.communities);

  Future<CommunityModel?> fetchCommunityById(String id) async {
    final row = await _fetchMap(ApiEndpoints.communityById(id));
    if (row == null) return null;
    return CommunityModel.fromJson(row);
  }

  Future<CommunityModel> createCommunity({
    required String name,
    required bool isPublic,
    String? description,
    String? imageUrl,
    List<String>? subjectKeys,
    String? educationStatus,
    String? schoolTrack,
    int? schoolGrade,
    int? universityYear,
    String? purpose,
    String? locale,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'visibility': isPublic ? 'public' : 'private',
      if (description != null && description.isNotEmpty)
        'description': description,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };
    if (isPublic) {
      if (subjectKeys != null && subjectKeys.isNotEmpty) {
        body['subjectKeys'] = subjectKeys;
      }
      if (educationStatus != null && educationStatus.isNotEmpty) {
        body['educationStatus'] = educationStatus;
      }
      if (schoolTrack != null && schoolTrack.isNotEmpty) {
        body['schoolTrack'] = schoolTrack;
      }
      if (schoolGrade != null) body['schoolGrade'] = schoolGrade;
      if (universityYear != null) body['universityYear'] = universityYear;
      if (purpose != null && purpose.isNotEmpty) body['purpose'] = purpose;
      body['locale'] = (locale == 'ar') ? 'ar' : 'en';
    }

    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.communities,
      data: body,
      dataFromJson: mapFromRawOrEmpty,
    );
    final row = env.data;
    if (row != null) return CommunityModel.fromJson(row);
    return CommunityModel(
      id: '',
      name: name,
      subtitle: description ?? '',
      description: description,
      isPublic: isPublic,
      isMember: true,
      myRole: 'owner',
    );
  }

  Future<CommunityModel> joinCommunity({
    String? communityId,
    String? inviteCode,
    String? inviteToken,
  }) async {
    final body = <String, dynamic>{};
    if (inviteCode != null && inviteCode.isNotEmpty) {
      body['inviteCode'] = inviteCode;
    } else if (inviteToken != null && inviteToken.isNotEmpty) {
      body['inviteToken'] = inviteToken;
    } else if (communityId != null && communityId.isNotEmpty) {
      body['communityId'] = communityId;
    }

    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.communitiesJoin,
      data: body,
      dataFromJson: mapFromRawOrEmpty,
    );
    final row = env.data;
    final targetCommunityId = communityId?.trim().isNotEmpty == true
        ? communityId!.trim()
        : readString(row ?? const {}, const ['communityId']);

    if (targetCommunityId.isNotEmpty) {
      final community = await fetchCommunityById(targetCommunityId);
      if (community != null) {
        final role = row != null ? readString(row, membershipRoleKeys) : '';
        return community.copyWith(
          isMember: true,
          myRole: role.isEmpty ? community.myRole ?? 'member' : role,
        );
      }
    }

    if (row != null) {
      return CommunityModel.fromJson(row, membership: row);
    }
    return CommunityModel(
      id: targetCommunityId,
      name: 'Community',
      subtitle: '',
      isMember: true,
    );
  }

  Future<CommunityModel> updateCommunity(
    String id, {
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    final env = await _api.put<Map<String, dynamic>>(
      ApiEndpoints.communityById(id),
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
      },
      dataFromJson: mapFromRawOrEmpty,
    );
    final row = env.data;
    if (row != null) return CommunityModel.fromJson(row);
    return CommunityModel(id: id, name: name ?? 'Community', subtitle: '');
  }

  Future<void> deleteCommunity(String id) async {
    await _api.delete<void>(ApiEndpoints.communityById(id));
  }

  Future<void> leaveCommunity(String id, {bool keepSaved = false}) async {
    await _api.post<void>(
      ApiEndpoints.communityLeave(id),
      data: keepSaved ? {'keepSaved': true} : null,
    );
  }

  Future<void> pinCommunity(String id) async {
    await _api.post<void>(ApiEndpoints.communityPin(id));
  }

  Future<void> unpinCommunity(String id) async {
    await _api.delete<void>(ApiEndpoints.communityPin(id));
  }

  Future<CommunityInviteInfo> fetchInvite(String id) async {
    final row = await _fetchMap(ApiEndpoints.communityInvite(id));
    return CommunityInviteInfo.fromJson(row);
  }

  Future<CommunityInviteInfo> regenerateInvite(String id) async {
    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.communityInviteRegenerate(id),
      dataFromJson: mapFromRawOrEmpty,
    );
    return CommunityInviteInfo.fromJson(env.data);
  }

  Future<List<CommunityGroupModel>> fetchChannels(String communityId) async {
    final rows = await _fetchList(ApiEndpoints.communityChannels(communityId));
    return rows
        .map((row) => CommunityGroupModel.fromJson(
              row,
              communityId: communityId,
            ))
        .where((g) => g.id.isNotEmpty)
        .toList();
  }

  Future<CommunityGroupModel> createChannel(
    String communityId, {
    required String title,
    String? description,
    String? imageUrl,
  }) async {
    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.communityChannels(communityId),
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
      dataFromJson: mapFromRawOrEmpty,
    );
    final row = env.data;
    if (row != null) {
      return CommunityGroupModel.fromJson(row, communityId: communityId);
    }
    return CommunityGroupModel(
      id: '',
      name: title,
      memberLabel: '0 members',
      icon: iconForGroupName(title),
      iconColor: colorForGroupName(title),
    );
  }

  Future<void> deleteChannel(String communityId, String channelId) async {
    await _api.delete<void>(
      ApiEndpoints.communityChannelById(communityId, channelId),
    );
  }

  Future<void> joinChannel(String communityId, String channelId) async {
    await _api.post<void>(
      ApiEndpoints.communityChannelJoin(communityId, channelId),
    );
  }

  Future<void> leaveChannel(String communityId, String channelId) async {
    await _api.delete<void>(
      ApiEndpoints.communityChannelJoin(communityId, channelId),
    );
  }

  Future<List<CommunityMemberModel>> fetchMembers(
    String communityId, {
    String? ownerUserId,
  }) async {
    final rows = await _fetchList(ApiEndpoints.communityMembers(communityId));
    return rows
        .map(
          (row) => CommunityMemberModel.fromJson(
            row,
            ownerUserId: ownerUserId,
          ),
        )
        .toList();
  }

  Future<void> removeMember(String communityId, String userId) async {
    await _api.delete<void>(
      ApiEndpoints.communityMemberByUserId(communityId, userId),
    );
  }

  Future<void> setMemberRole(
    String communityId,
    String userId, {
    required String role,
  }) async {
    await _api.patch<void>(
      ApiEndpoints.communityMemberByUserId(communityId, userId),
      data: {'role': role},
    );
  }

  Future<List<CommunityChatMessage>> fetchMessages(
    String communityId,
    String channelId,
  ) async {
    final rows = await _fetchList(
      ApiEndpoints.communityChannelMessages(communityId, channelId),
    );
    return rows.map(CommunityChatMessage.fromJson).toList();
  }

  Future<CommunityChatMessage> postMessage(
    String communityId,
    String channelId, {
    required String messageContent,
    String inputType = 'text',
  }) async {
    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.communityChannelMessages(communityId, channelId),
      data: {
        'messageContent': messageContent,
        'inputType': inputType,
      },
      dataFromJson: mapFromRawOrEmpty,
    );
    final row = env.data;
    if (row != null) return CommunityChatMessage.fromJson(row);
    return CommunityChatMessage(
      id: '',
      senderName: '',
      senderUserId: '',
      text: messageContent,
      sentAt: DateTime.now(),
    );
  }

  Future<RecommendedFeed> fetchRecommended({
    String section = 'for_you',
    int limit = 20,
    String locale = 'en',
  }) async {
    final data = await _fetchMap(
      ApiEndpoints.communitiesRecommended,
      queryParameters: {
        'section': section,
        'limit': limit,
        'locale': locale,
      },
    );
    if (data == null) {
      return RecommendedFeed(section: section);
    }
    return RecommendedFeed.fromJson(data);
  }

  Future<DiscoverCategories> fetchDiscoverCategories({String locale = 'en'}) async {
    final data = await _fetchMap(
      ApiEndpoints.communitiesDiscoverCategories,
      queryParameters: {'locale': locale},
    );
    if (data == null) return const DiscoverCategories();
    return DiscoverCategories.fromJson(data);
  }

  Future<DiscoverBrowsePage> browseDiscover({
    String? subject,
    String? educationStatus,
    String? purpose,
    String? q,
    int limit = 20,
    int offset = 0,
    String locale = 'en',
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'locale': locale,
    };
    if (subject != null && subject.isNotEmpty) query['subject'] = subject;
    if (educationStatus != null && educationStatus.isNotEmpty) {
      query['educationStatus'] = educationStatus;
    }
    if (purpose != null && purpose.isNotEmpty) query['purpose'] = purpose;
    if (q != null && q.isNotEmpty) query['q'] = q;

    final data = await _fetchMap(
      ApiEndpoints.communitiesDiscover,
      queryParameters: query,
    );
    if (data == null) {
      return const DiscoverBrowsePage();
    }
    return DiscoverBrowsePage.fromJson(data);
  }
}
