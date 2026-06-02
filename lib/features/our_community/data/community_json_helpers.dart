import 'package:flutter/material.dart';

import 'package:mishka_app/core/utils/app_colors.dart';

List<Map<String, dynamic>> listOfMapsFromRaw(Object? raw) {
  final list = (raw as List?) ?? const [];
  return list
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> mapFromRawOrEmpty(Object? raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return {};
}

int parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool parseBool(Object? value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  final s = value.toString().toLowerCase();
  return s == 'true' || s == '1' || s == 'yes';
}

String readString(Map<String, dynamic> row, List<String> keys) {
  for (final key in keys) {
    final value = row[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

String visibilityFromRow(Map<String, dynamic> row) {
  final raw = readString(row, const [
    'visibility',
    'communityVisibility',
    'type',
  ]).toLowerCase();
  if (raw.contains('private')) return 'private';
  if (raw.contains('public')) return 'public';
  if (parseBool(row['isPrivate'])) return 'private';
  if (parseBool(row['isPublic'])) return 'public';
  return 'public';
}

bool isPublicVisibility(String visibility) => visibility != 'private';

IconData iconForGroupName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('flutter')) return Icons.flutter_dash;
  if (lower.contains('ui') || lower.contains('ux') || lower.contains('design')) {
    return Icons.palette_outlined;
  }
  if (lower.contains('cyber') || lower.contains('security')) {
    return Icons.shield_outlined;
  }
  if (lower.contains('network')) return Icons.language_outlined;
  if (lower.contains('ai')) return Icons.psychology_outlined;
  return Icons.groups_outlined;
}

Color colorForGroupName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('flutter')) return AppColors.blue;
  if (lower.contains('ui') || lower.contains('ux')) return AppColors.mainGold;
  if (lower.contains('cyber') || lower.contains('security')) return AppColors.blue;
  if (lower.contains('network')) return AppColors.lightText;
  if (lower.contains('ai')) return AppColors.mainDark;
  return AppColors.mainGold;
}

String memberCountLabel(int count) {
  if (count == 1) return '1 member';
  return '$count members';
}

/// Channel list uses `createdByDisplay`; message list uses `senderDisplay`.
const messageSenderNameKeys = [
  'senderDisplay',
  'senderDisplayName',
  'senderFullName',
  'senderName',
  'authorDisplayName',
  'authorName',
  'userDisplayName',
  'createdByDisplay',
  'displayName',
];

/// Membership rows (`GET /members`, `user-communities`).
const membershipRoleKeys = [
  'role',
  'communityRole',
  'membershipRole',
  'memberRole',
];

/// Message payloads — backend sends `senderRole` with `senderDisplay`.
const messageSenderRoleKeys = [
  'senderRole',
  'senderCommunityRole',
  'communityRole',
  'membershipRole',
  'memberRole',
];

String formatCommunityRole(String raw) {
  final lower = raw.trim().toLowerCase();
  if (lower.isEmpty) return 'Member';
  if (lower.contains('owner')) return 'Owner';
  if (lower.contains('admin')) return 'Admin';
  if (lower.contains('member')) return 'Member';
  if (raw.length == 1) return raw.toUpperCase();
  return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
}

/// Canonical display role for any user in a community.
String resolveMemberCommunityRole({
  required String userId,
  String? rawRole,
  String? formattedRole,
  bool isOwnerRecord = false,
  String? ownerUserId,
  String? memberListRole,
}) {
  if (userId.isNotEmpty &&
      ownerUserId != null &&
      ownerUserId.isNotEmpty &&
      ownerUserId == userId) {
    return 'Owner';
  }
  if (isOwnerRecord) return 'Owner';

  if (memberListRole != null && memberListRole.trim().isNotEmpty) {
    final fromList = formatCommunityRole(memberListRole);
    if (fromList != 'Member') return fromList;
  }

  if (rawRole != null && rawRole.trim().isNotEmpty) {
    return formatCommunityRole(rawRole);
  }
  if (formattedRole != null && formattedRole.trim().isNotEmpty) {
    return formatCommunityRole(formattedRole);
  }
  if (memberListRole != null && memberListRole.trim().isNotEmpty) {
    return formatCommunityRole(memberListRole);
  }

  return 'Member';
}

/// Role for the signed-in user (membership + members list + owner id).
String resolveCurrentUserCommunityRole({
  required String userId,
  String? membershipRole,
  String? ownerUserId,
  String? memberListRole,
}) {
  return resolveMemberCommunityRole(
    userId: userId,
    rawRole: membershipRole,
    ownerUserId: ownerUserId,
    memberListRole: memberListRole,
  );
}

String displayNameFromUserMap(Map<String, dynamic> userMap) {
  final fullName = readString(userMap, const [
    'senderDisplay',
    'fullName',
    'displayName',
    'name',
    'senderDisplayName',
    'createdByDisplay',
  ]);
  if (fullName.isNotEmpty) return fullName;

  final first = readString(userMap, const ['firstName']);
  final last = readString(userMap, const ['lastName']);
  final combined = '$first $last'.trim();
  if (combined.isNotEmpty) return combined;

  final username = readString(userMap, const ['username']);
  if (username.isNotEmpty) return username;

  return readString(userMap, const ['email']);
}

String groupCountLabel(int count) {
  if (count == 1) return '1 group';
  return '$count groups';
}

String buildCommunitySubtitle({
  required int memberCount,
  required int groupCount,
  String? description,
  bool preferDescription = false,
}) {
  if (preferDescription && description != null && description.isNotEmpty) {
    return description;
  }
  if (memberCount > 0 || groupCount > 0) {
    return '${memberCountLabel(memberCount)}   ${groupCountLabel(groupCount)}';
  }
  return description ?? '';
}
