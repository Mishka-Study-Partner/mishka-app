import 'package:mishka_app/l10n/app_localizations.dart';

const _legacyCommunityName = 'Community';
const _legacyGroupName = 'Group';
const _legacyMemberName = 'Member';

/// Localized label for API role strings (Owner, Admin, Member).
String communityRoleDisplayLabel(String role, AppLocalizations l10n) {
  switch (role) {
    case 'Owner':
      return l10n.communityRoleOwner;
    case 'Admin':
      return l10n.communityRoleAdmin;
    case 'Member':
      return l10n.communityRoleMember;
    default:
      return role;
  }
}

String communityDisplayName(String name, AppLocalizations l10n) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == _legacyCommunityName) {
    return l10n.communityFallbackName;
  }
  return trimmed;
}

String communityGroupDisplayName(String name, AppLocalizations l10n) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == _legacyGroupName) {
    return l10n.communityFallbackGroupName;
  }
  return trimmed;
}

String communityMemberDisplayName(String name, AppLocalizations l10n) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == _legacyMemberName) {
    return l10n.communityFallbackMemberName;
  }
  return trimmed;
}
