import 'package:mishka_app/core/network/api_service.dart';

import 'community_chat_bundle.dart';
import 'community_create_params.dart';
import 'community_discover_models.dart';
import 'community_invite_resolver.dart';
import 'community_models.dart';
import 'community_pinned_store.dart';
import 'community_remote_data_source.dart';

class CommunityRepository {
  CommunityRepository({CommunityRemoteDataSource? remote})
      : _remote = remote ?? CommunityRemoteDataSource(ApiService());

  final CommunityRemoteDataSource _remote;
  List<Map<String, dynamic>>? _membershipsCache;
  RecommendedFeed? _recommendedCache;
  DateTime? _recommendedCachedAt;
  String? _recommendedCacheKey;
  final Map<String, _CommunityDetailCacheEntry> _communityDetailCache = {};
  static const _communityDetailCacheTtl = Duration(seconds: 45);

  void _invalidateMembershipsCache() => _membershipsCache = null;

  void _invalidateCommunityDetailCache([String? id]) {
    if (id == null) {
      _communityDetailCache.clear();
    } else {
      _communityDetailCache.remove(id);
    }
  }

  void _invalidateRecommendedCache() {
    _recommendedCache = null;
    _recommendedCachedAt = null;
    _recommendedCacheKey = null;
  }

  Future<List<Map<String, dynamic>>> _fetchMembershipsCached() async {
    _membershipsCache ??= await _remote.fetchMemberships();
    return _membershipsCache!;
  }

  Future<RecommendedFeed> loadRecommended({
    String section = 'for_you',
    int limit = 20,
    String locale = 'en',
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$section|$limit|$locale';
    final now = DateTime.now();
    if (!forceRefresh &&
        _recommendedCache != null &&
        _recommendedCachedAt != null &&
        _recommendedCacheKey == cacheKey &&
        now.difference(_recommendedCachedAt!) <
            const Duration(minutes: 1)) {
      return _recommendedCache!;
    }
    final feed = await _remote.fetchRecommended(
      section: section,
      limit: limit,
      locale: locale,
    );
    _recommendedCache = feed;
    _recommendedCachedAt = now;
    _recommendedCacheKey = cacheKey;
    return feed;
  }

  Future<DiscoverCategories> loadDiscoverCategories({String locale = 'en'}) =>
      _remote.fetchDiscoverCategories(locale: locale);

  Future<DiscoverBrowsePage> browseDiscover({
    String? subject,
    String? educationStatus,
    String? purpose,
    String? q,
    int limit = 20,
    int offset = 0,
    String locale = 'en',
  }) =>
      _remote.browseDiscover(
        subject: subject,
        educationStatus: educationStatus,
        purpose: purpose,
        q: q,
        limit: limit,
        offset: offset,
        locale: locale,
      );

  Future<CommunityHubData> loadHub() async {
    await CommunityPinnedStore.ensureLoaded();
    _invalidateMembershipsCache();
    final memberships = await _fetchMembershipsCached();
    final communities = await _remote.fetchCommunities();

    final membershipByCommunityId = <String, Map<String, dynamic>>{};
    for (final membership in memberships) {
      final communityId = _communityIdFromMembership(membership);
      if (communityId.isEmpty) continue;
      membershipByCommunityId[communityId] = membership;
    }

    final merged = <String, CommunityModel>{};

    for (final row in communities) {
      final id = _communityIdFromRow(row);
      if (id.isEmpty) continue;
      merged[id] = CommunityModel.fromJson(
        row,
        membership: membershipByCommunityId[id],
      );
    }

    for (final membership in memberships) {
      final id = _communityIdFromMembership(membership);
      if (id.isEmpty || merged.containsKey(id)) continue;
      merged[id] = CommunityModel.fromJson(
        membership,
        membership: membership,
      );
    }

    var all = merged.values.toList();
    await CommunityPinnedStore.reconcileWithMemberships(
      all.where((c) => c.isMember),
    );
    all = all.map(_applyPinnedState).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final saved = <CommunityModel>[];
    final private = <CommunityModel>[];
    final public = <CommunityModel>[];

    for (final community in all) {
      if (!community.isMember) continue;

      if (community.isPinned) {
        saved.add(community);
        continue;
      }
      if (community.isPublic) {
        public.add(community);
      } else {
        private.add(community);
      }
    }

    return CommunityHubData(
      saved: saved,
      privateCommunities: private,
      publicCommunities: public,
    );
  }

  Future<CommunityModel?> refreshCommunity(
    String id, {
    CommunityModel? seed,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _communityDetailCache[id];
      if (cached != null &&
          DateTime.now().difference(cached.loadedAt) < _communityDetailCacheTtl) {
        return _mergeCommunityDetail(cached.model, id: id, seed: seed);
      }
    }

    final community = await _remote.fetchCommunityById(id);
    if (community == null) return seed;

    final merged = await _mergeCommunityDetail(community, id: id, seed: seed);
    if (merged != null) {
      _communityDetailCache[id] = _CommunityDetailCacheEntry(
        merged,
        DateTime.now(),
      );
    }
    return merged;
  }

  Future<CommunityModel?> _mergeCommunityDetail(
    CommunityModel community, {
    required String id,
    CommunityModel? seed,
  }) async {
    await CommunityPinnedStore.ensureLoaded();

    for (final membership in await _fetchMembershipsCached()) {
      if (_communityIdFromMembership(membership) != id) continue;
      final role = (membership['role'] ?? '').toString();
      final fromMembership = CommunityModel.fromJson(
        membership,
        membership: membership,
      );
      return _applyPinnedState(
        community.copyWith(
          isMember: true,
          myRole: role.isEmpty ? (seed?.myRole ?? community.myRole) : role,
          isPinned: community.isPinned || fromMembership.isPinned,
          ownerUserId: community.ownerUserId ?? seed?.ownerUserId,
        ),
      );
    }

    return _applyPinnedState(
      community.copyWith(
        myRole: community.myRole ?? seed?.myRole,
        ownerUserId: community.ownerUserId ?? seed?.ownerUserId,
      ),
    );
  }

  Future<CommunityModel> createCommunity({
    required String name,
    required bool isPublic,
    String? description,
    CommunityCreateParams? discovery,
  }) async {
    _invalidateMembershipsCache();
    _invalidateRecommendedCache();
    _invalidateCommunityDetailCache();
    final d = discovery;
    return _remote.createCommunity(
      name: name,
      isPublic: isPublic,
      description: description,
      subjectKeys: d?.subjectKeys,
      educationStatus: d?.educationStatus,
      schoolTrack: d?.schoolTrack,
      schoolGrade: d?.schoolGrade,
      universityYear: d?.universityYear,
      purpose: d?.purpose,
      locale: d?.locale,
    );
  }

  Future<void> setMemberRole(
    String communityId,
    String userId, {
    required String role,
  }) =>
      _remote.setMemberRole(communityId, userId, role: role);

  Future<CommunityModel> joinByInviteCode(String code) async {
    _invalidateMembershipsCache();
    _invalidateCommunityDetailCache();
    return _remote.joinCommunity(inviteCode: code.trim());
  }

  Future<CommunityModel> joinPublicCommunity(String communityId) async {
    _invalidateMembershipsCache();
    _invalidateRecommendedCache();
    _invalidateCommunityDetailCache(communityId);
    return _remote.joinCommunity(communityId: communityId);
  }

  Future<List<CommunityGroupModel>> loadChannels(String communityId) =>
      _remote.fetchChannels(communityId);

  Future<CommunityGroupModel> createChannel(
    String communityId, {
    required String title,
    String? description,
  }) async {
    final group = await _remote.createChannel(
      communityId,
      title: title,
      description: description,
    );
    if (group.id.isEmpty) return group;

    try {
      await _remote.joinChannel(communityId, group.id);
      return group.copyWith(joined: true);
    } catch (_) {
      return group;
    }
  }

  Future<void> ensureChannelJoined(String communityId, String channelId) =>
      _remote.joinChannel(communityId, channelId);

  Future<void> deleteChannel(String communityId, String channelId) =>
      _remote.deleteChannel(communityId, channelId);

  Future<void> joinChannel(String communityId, String channelId) =>
      _remote.joinChannel(communityId, channelId);

  Future<void> leaveChannel(String communityId, String channelId) =>
      _remote.leaveChannel(communityId, channelId);

  Future<List<CommunityMemberModel>> loadMembers(
    String communityId, {
    String? ownerUserId,
  }) async {
    final ownerId = ownerUserId ??
        (await refreshCommunity(communityId))?.ownerUserId;
    return _remote.fetchMembers(communityId, ownerUserId: ownerId);
  }

  Future<void> removeMember(String communityId, String userId) =>
      _remote.removeMember(communityId, userId);

  Future<void> leaveCommunity(String id, {bool keepSaved = false}) async {
    await _remote.leaveCommunity(id, keepSaved: keepSaved);
    _invalidateMembershipsCache();
    _invalidateCommunityDetailCache(id);
  }

  Future<void> deleteCommunity(String id) async {
    await _remote.deleteCommunity(id);
    _invalidateMembershipsCache();
    _invalidateCommunityDetailCache(id);
  }

  Future<void> pinCommunity(String id) async {
    await _remote.pinCommunity(id);
    await CommunityPinnedStore.pin(id);
    _invalidateMembershipsCache();
    _invalidateRecommendedCache();
    _invalidateCommunityDetailCache(id);
  }

  Future<void> unpinCommunity(String id) async {
    await _remote.unpinCommunity(id);
    await CommunityPinnedStore.unpin(id);
    _invalidateMembershipsCache();
    _invalidateRecommendedCache();
    _invalidateCommunityDetailCache(id);
  }

  Future<void> inviteMemberByEmail(String communityId, String email) =>
      _remote.inviteMember(communityId, email: email);

  Future<void> inviteMemberByUsername(String communityId, String username) =>
      _remote.inviteMember(communityId, username: username);

  Future<CommunityInviteInfo> getInvite(
    String id, {
    CommunityModel? community,
  }) async {
    final hint = community;
    try {
      final api = await _remote.fetchInvite(id);
      if (hint != null) return CommunityInviteResolver.merge(api, hint);
      return api;
    } catch (_) {
      final model = hint ?? await refreshCommunity(id);
      if (model != null) return CommunityInviteResolver.fromCommunity(model);
      rethrow;
    }
  }

  Future<CommunityInviteInfo> regenerateInvite(
    String id, {
    CommunityModel? community,
  }) async {
    if (community?.isPublic == true) {
      return CommunityInviteResolver.fromCommunity(community!);
    }
    final api = await _remote.regenerateInvite(id);
    if (community != null) return CommunityInviteResolver.merge(api, community);
    return api;
  }

  Future<CommunityModel> updateCommunity(
    String id, {
    String? name,
    String? description,
  }) async {
    _invalidateCommunityDetailCache(id);
    return _remote.updateCommunity(
      id,
      name: name,
      description: description,
    );
  }

  /// One round-trip set for group chat: community, members, messages with roles.
  Future<CommunityChatBundle> loadChatBundle(
    String communityId,
    String channelId, {
    CommunityModel? seedCommunity,
  }) async {
    final community =
        await refreshCommunity(communityId, seed: seedCommunity) ??
            seedCommunity;
    if (community == null) {
      throw StateError('Community not found');
    }

    final members = await _remote.fetchMembers(
      communityId,
      ownerUserId: community.ownerUserId,
    );

    final memberNamesByUserId = <String, String>{};
    final memberRolesByUserId = <String, String>{};
    for (final member in members) {
      if (member.userId.isEmpty) continue;
      if (member.name.isNotEmpty) {
        memberNamesByUserId[member.userId] = member.name;
      }
      memberRolesByUserId[member.userId] = member.role;
    }

    final messages = (await _remote.fetchMessages(communityId, channelId))
        .map(
          (message) => message.withResolvedRole(
            rolesByUserId: memberRolesByUserId,
            ownerUserId: community.ownerUserId,
          ),
        )
        .toList();

    return CommunityChatBundle(
      community: community,
      members: members,
      messages: messages,
      memberNamesByUserId: memberNamesByUserId,
      memberRolesByUserId: memberRolesByUserId,
    );
  }

  Future<List<CommunityChatMessage>> loadMessages(
    String communityId,
    String channelId,
  ) async {
    final bundle = await loadChatBundle(communityId, channelId);
    return bundle.messages;
  }

  Future<CommunityChatMessage> postMessage(
    String communityId,
    String channelId,
    String text,
  ) =>
      _remote.postMessage(
        communityId,
        channelId,
        messageContent: text,
      );

  String _communityIdFromMembership(Map<String, dynamic> row) {
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

  CommunityModel _applyPinnedState(CommunityModel community) {
    final pinned =
        community.isPinned || CommunityPinnedStore.isPinned(community.id);
    if (pinned == community.isPinned) return community;
    return community.copyWith(isPinned: pinned);
  }
}

class _CommunityDetailCacheEntry {
  const _CommunityDetailCacheEntry(this.model, this.loadedAt);

  final CommunityModel model;
  final DateTime loadedAt;
}
