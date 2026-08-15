import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/our_community/data/community_material_ref.dart';
import '../../../generated/assets.dart';
import 'community_json_helpers.dart';

class CommunityModel {
  final String id;
  final String name;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final String imageAsset;
  final bool isLongSubtitle;
  final int memberCount;
  final int groupCount;
  final bool isPublic;
  final bool isMember;
  final bool isPinned;
  final DateTime? pinnedAt;
  final String? category;
  final String? myRole;
  final String? ownerUserId;
  final String? inviteCode;
  final String? inviteToken;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.imageAsset = Assets.imagesOurCommunity,
    this.isLongSubtitle = false,
    this.memberCount = 0,
    this.groupCount = 0,
    this.isPublic = true,
    this.isMember = false,
    this.isPinned = false,
    this.pinnedAt,
    this.category,
    this.myRole,
    this.ownerUserId,
    this.inviteCode,
    this.inviteToken,
  });

  bool isOwnerUser(String userId) {
    if (userId.isEmpty) return false;
    if (ownerUserId != null && ownerUserId == userId) return true;
    return (myRole ?? '').toLowerCase().contains('owner');
  }

  bool get isOwner =>
      (myRole ?? '').toLowerCase().contains('owner');

  bool get canManage =>
      isOwner || (myRole ?? '').toLowerCase().contains('admin');

  bool canManageFor(String userId) {
    if (isOwnerUser(userId)) return true;
    return (myRole ?? '').toLowerCase().contains('admin');
  }

  CommunityModel copyWith({
    String? name,
    String? subtitle,
    String? description,
    String? imageUrl,
    int? memberCount,
    int? groupCount,
    bool? isPublic,
    bool? isMember,
    bool? isPinned,
    DateTime? pinnedAt,
    String? category,
    String? myRole,
    String? ownerUserId,
    String? inviteCode,
    String? inviteToken,
  }) {
    return CommunityModel(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset,
      isLongSubtitle: isLongSubtitle,
      memberCount: memberCount ?? this.memberCount,
      groupCount: groupCount ?? this.groupCount,
      isPublic: isPublic ?? this.isPublic,
      isMember: isMember ?? this.isMember,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      category: category ?? this.category,
      myRole: myRole ?? this.myRole,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteToken: inviteToken ?? this.inviteToken,
    );
  }

  static CommunityModel fromJson(
    Map<String, dynamic> row, {
    Map<String, dynamic>? membership,
  }) {
    final nested = row['community'];
    final source = nested is Map
        ? Map<String, dynamic>.from(nested)
        : row;

    final rowCommunityId = readString(row, const ['communityId']);
    final isMembershipOnly = nested is! Map &&
        rowCommunityId.isNotEmpty &&
        readString(source, const ['name', 'title', 'communityName']).isEmpty;

    final id = isMembershipOnly
        ? rowCommunityId
        : readString(source, const ['id', 'communityId']) ==
                readString(row, const ['id'])
            ? readString(source, const ['id', 'communityId'])
            : readString(row, const ['communityId', 'id']);

    final name = readString(source, const [
      'name',
      'title',
      'communityName',
    ]);

    final description = readString(source, const [
      'description',
      'about',
      'bio',
    ]);

    final imageUrl = readString(source, const [
      'imageUrl',
      'avatarUrl',
      'iconUrl',
      'image',
    ]);

    final visibility = membership != null
        ? visibilityFromRow({...source, ...membership})
        : visibilityFromRow(source);

    final memberCount = parseCommunityMemberCount(source, row: row);

    final groupCount = parseCommunityGroupCount(source, row: row);

    final isMember = membership != null ||
        parseBool(row['isMember']) ||
        parseBool(source['isMember']) ||
        parseBool(row['joined']) ||
        parseBool(source['joined']);

    final isPinned = parseBool(membership?['isPinned']) ||
        parseBool(membership?['pinned']) ||
        parseBool(membership?['saved']) ||
        parseBool(membership?['isSaved']) ||
        parseBool(membership?['bookmarked']) ||
        parseBool(row['isPinned']) ||
        parseBool(row['pinned']) ||
        parseBool(row['saved']) ||
        parseBool(row['isSaved']) ||
        parseBool(source['isPinned']) ||
        parseBool(source['pinned']) ||
        parseBool(source['saved']) ||
        parseBool(source['isSaved']) ||
        (membership != null &&
            readString(
              Map<String, dynamic>.from(membership),
              const ['pinnedAt', 'savedAt'],
            ).isNotEmpty);

    DateTime? pinnedAt;
    for (final key in const ['pinnedAt', 'savedAt']) {
      final raw = membership?[key] ?? row[key] ?? source[key];
      if (raw != null) {
        pinnedAt = DateTime.tryParse(raw.toString());
        if (pinnedAt != null) break;
      }
    }

    final category = readString(source, const ['category']).isEmpty
        ? (readString(row, const ['category']).isEmpty
            ? null
            : readString(row, const ['category']))
        : readString(source, const ['category']);

    final myRole = readString(membership ?? row, membershipRoleKeys);

    final ownerUserId = readString(source, const [
      'ownerUserId',
      'ownerId',
      'createdByUserId',
    ]);

    final inviteCode = readString(source, const ['inviteCode', 'code']);
    final inviteToken = readString(source, const ['inviteToken', 'token']);

    final isPublicCommunity = isPublicVisibility(visibility);
    final preferDescription = isPublicCommunity && !isMember;

    return CommunityModel(
      id: id,
      name: name,
      description: description.isEmpty ? null : description,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      subtitle: buildCommunitySubtitle(
        memberCount: memberCount,
        groupCount: groupCount,
        description: description.isEmpty ? null : description,
        preferDescription: preferDescription,
      ),
      isLongSubtitle: preferDescription,
      memberCount: memberCount,
      groupCount: groupCount,
      isPublic: isPublicCommunity,
      isMember: isMember,
      isPinned: isPinned,
      pinnedAt: pinnedAt,
      category: category?.isEmpty == true ? null : category,
      myRole: myRole.isEmpty ? null : myRole,
      ownerUserId: ownerUserId.isEmpty ? null : ownerUserId,
      inviteCode: inviteCode.isEmpty ? null : inviteCode,
      inviteToken: inviteToken.isEmpty ? null : inviteToken,
    );
  }
}

class CommunityHubData {
  const CommunityHubData({
    this.saved = const [],
    this.privateCommunities = const [],
    this.publicCommunities = const [],
  });

  final List<CommunityModel> saved;
  final List<CommunityModel> privateCommunities;
  final List<CommunityModel> publicCommunities;

  bool get isEmpty =>
      saved.isEmpty &&
      privateCommunities.isEmpty &&
      publicCommunities.isEmpty;

  /// Communities the user has already joined (any section).
  Set<String> get memberCommunityIds => {
        for (final c in saved) c.id,
        for (final c in privateCommunities) c.id,
        for (final c in publicCommunities) c.id,
      };
}

class CommunityGroupModel {
  final String id;
  final String name;
  final String memberLabel;
  final String? description;
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;
  final bool joined;

  const CommunityGroupModel({
    required this.id,
    required this.name,
    required this.memberLabel,
    this.description,
    this.imageUrl,
    required this.icon,
    this.iconColor = AppColors.mainGold,
    this.joined = false,
  });

  static CommunityGroupModel fromJson(
    Map<String, dynamic> row, {
    required String communityId,
  }) {
    final id = readString(row, const ['id', 'channelId']);
    final name = readString(row, const ['title', 'name', 'channelName']);
    final description = readString(row, const ['description', 'about']);
    final imageUrl = readString(row, const ['imageUrl', 'iconUrl']);
    final memberCount = parseInt(
      row['memberCount'] ?? row['membersCount'] ?? row['member_count'],
    );
    final joined = parseBool(row['joined'], defaultValue: false);
    final iconKey = name.isEmpty ? 'group' : name;

    return CommunityGroupModel(
      id: id,
      name: name,
      description: description.isEmpty ? null : description,
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      memberLabel: memberCountLabel(memberCount),
      icon: iconForGroupName(iconKey),
      iconColor: colorForGroupName(iconKey),
      joined: joined,
    );
  }

  CommunityGroupModel copyWith({bool? joined}) {
    return CommunityGroupModel(
      id: id,
      name: name,
      memberLabel: memberLabel,
      description: description,
      imageUrl: imageUrl,
      icon: icon,
      iconColor: iconColor,
      joined: joined ?? this.joined,
    );
  }
}

class CommunityMemberModel {
  final String userId;
  final String name;
  final String role;
  final List<String> groups;

  const CommunityMemberModel({
    required this.userId,
    required this.name,
    required this.role,
    this.groups = const [],
  });

  static CommunityMemberModel fromJson(
    Map<String, dynamic> row, {
    String? ownerUserId,
  }) {
    final user = row['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : row;

    final userId = readString(row, const ['userId', 'id']) ==
            readString(userMap, const ['id'])
        ? readString(row, const ['userId', 'id'])
        : readString(userMap, const ['id', 'userId']);

    final nameFromUser = displayNameFromUserMap(userMap);
    final name = nameFromUser.isNotEmpty
        ? nameFromUser
        : readString(row, const ['displayName', 'fullName', 'name']);

    final roleRaw = readString(row, membershipRoleKeys);
    final role = resolveMemberCommunityRole(
      userId: userId,
      rawRole: roleRaw,
      isOwnerRecord: parseBool(row['isOwnerRecord']),
      ownerUserId: ownerUserId,
    );

    final groupsRaw = row['groups'] ?? row['channels'];
    final groups = groupsRaw is List
        ? groupsRaw
            .map((g) {
              if (g is Map) {
                return readString(
                  Map<String, dynamic>.from(g),
                  const ['title', 'name'],
                );
              }
              return g?.toString() ?? '';
            })
            .where((g) => g.isNotEmpty)
            .toList()
        : const <String>[];

    return CommunityMemberModel(
      userId: userId,
      name: name,
      role: role,
      groups: groups,
    );
  }
}

class CommunityInviteInfo {
  const CommunityInviteInfo({
    this.inviteCode,
    this.inviteToken,
    this.shareUrl,
    this.supported = true,
    this.visibility,
    this.hint,
  });

  final String? inviteCode;
  final String? inviteToken;
  final String? shareUrl;
  final bool supported;
  final String? visibility;
  final String? hint;

  bool get hasShareable =>
      (inviteCode?.isNotEmpty ?? false) ||
      (inviteToken?.isNotEmpty ?? false) ||
      (shareUrl?.isNotEmpty ?? false);

  static CommunityInviteInfo fromJson(Object? raw) {
    final row = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final code = readString(row, const ['inviteCode', 'code']);
    final token = readString(row, const ['inviteToken', 'token']);
    final url = readString(row, const [
      'shareUrl',
      'shareLink',
      'linkUrl',
      'url',
    ]);
    return CommunityInviteInfo(
      inviteCode: code.isEmpty ? null : code,
      inviteToken: token.isEmpty ? null : token,
      shareUrl: url.isEmpty ? null : url,
      supported: parseBool(row['supported'], defaultValue: true),
      visibility: readString(row, const ['visibility']).isEmpty
          ? null
          : readString(row, const ['visibility']),
      hint: readString(row, const ['hint']).isEmpty
          ? null
          : readString(row, const ['hint']),
    );
  }
}

class CommunityChatMessage {
  const CommunityChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.senderUserId = '',
    this.senderRole = '',
    this.isMishka = false,
    this.isShared = false,
    this.inputType = '',
    this.materialRef,
    this.inlineToolData,
  });

  final String id;
  final String senderName;
  final String senderUserId;
  final String senderRole;
  final String text;
  final DateTime? sentAt;
  final bool isMishka;
  final bool isShared;
  final String inputType;
  final CommunityMaterialRef? materialRef;
  final Map<String, dynamic>? inlineToolData;

  bool get hasSharedMaterial =>
      materialRef != null || inlineToolData != null;

  static CommunityChatMessage fromJson(Map<String, dynamic> row) {
    final id = readString(row, const ['id', 'messageId']);
    final content = readString(row, const [
      'messageContent',
      'content',
      'text',
      'body',
    ]);
    // Prefer top-level `senderDisplay` + `senderRole` from message API.
    var sender = readString(row, messageSenderNameKeys);
    var senderUserId = readString(row, const [
      'senderUserId',
      'userId',
      'createdByUserId',
      'authorId',
    ]);

    var senderRole = readString(row, messageSenderRoleKeys);

    for (final key in const [
      'sender',
      'user',
      'createdBy',
      'author',
      'senderUser',
    ]) {
      final nested = row[key];
      if (nested is! Map) continue;
      final userMap = Map<String, dynamic>.from(nested);
      if (sender.isEmpty) {
        sender = displayNameFromUserMap(userMap);
      }
      if (senderUserId.isEmpty) {
        senderUserId = readString(userMap, const ['id', 'userId']);
      }
      if (senderRole.isEmpty) {
        senderRole = readString(userMap, messageSenderRoleKeys);
        if (senderRole.isEmpty) {
          senderRole = readString(userMap, membershipRoleKeys);
        }
      }
    }

    final formattedRole =
        senderRole.isEmpty ? '' : formatCommunityRole(senderRole);

    final inputType = readString(row, const ['inputType', 'source']).toLowerCase();
    final isMishka = inputType.contains('mishka') ||
        sender.toLowerCase().contains('mishka') ||
        parseBool(row['isMishka']);

    final materialRef = CommunityMaterialRef.tryParseFromMessage(
      inputType: inputType,
      messageContent: content,
    );
    final inlineToolData = _tryParseInlineToolData(
      inputType: inputType,
      messageContent: content,
    );

    final isShared = materialRef != null ||
        inlineToolData != null ||
        inputType == 'material' ||
        parseBool(row['isShared']) ||
        inputType.contains('shared') ||
        inputType.contains('saved') ||
        content.toLowerCase().contains('shared from mishka');

    final displayText = materialRef != null
        ? (materialRef.note ?? '')
        : (inlineToolData != null ? '' : content);

    DateTime? sentAt;
    for (final key in const ['createdAt', 'sentAt', 'timestamp']) {
      final raw = row[key];
      if (raw != null) {
        sentAt = DateTime.tryParse(raw.toString());
        if (sentAt != null) break;
      }
    }

    return CommunityChatMessage(
      id: id,
      senderName: sender.isEmpty ? (isMishka ? 'Mishka' : '') : sender,
      senderUserId: senderUserId,
      senderRole: formattedRole,
      text: displayText,
      sentAt: sentAt,
      isMishka: isMishka,
      isShared: isShared,
      inputType: inputType,
      materialRef: materialRef,
      inlineToolData: inlineToolData,
    );
  }

  static Map<String, dynamic>? _tryParseInlineToolData({
    required String inputType,
    required String messageContent,
  }) {
    if (inputType != 'tool_preview') return null;
    final trimmed = messageContent.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;
      return normalizeToolData(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  CommunityChatMessage copyWith({
    String? senderRole,
  }) {
    return CommunityChatMessage(
      id: id,
      senderName: senderName,
      senderUserId: senderUserId,
      senderRole: senderRole ?? this.senderRole,
      text: text,
      sentAt: sentAt,
      isMishka: isMishka,
      isShared: isShared,
      inputType: inputType,
      materialRef: materialRef,
      inlineToolData: inlineToolData,
    );
  }

  CommunityChatMessage withResolvedRole({
    required Map<String, String> rolesByUserId,
    String? ownerUserId,
  }) {
    if (isMishka) return this;
    final role = resolveMemberCommunityRole(
      userId: senderUserId,
      formattedRole: senderRole,
      memberListRole: rolesByUserId[senderUserId],
      ownerUserId: ownerUserId,
    );
    if (role == senderRole) return this;
    return copyWith(senderRole: role);
  }

  String get timeLabel {
    if (sentAt == null) return '';
    final hour = sentAt!.hour % 12 == 0 ? 12 : sentAt!.hour % 12;
    final minute = sentAt!.minute.toString().padLeft(2, '0');
    final suffix = sentAt!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
