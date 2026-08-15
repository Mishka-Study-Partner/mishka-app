import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_current_user.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../../utils/community_navigation.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_dialogs.dart';
import '../widgets/member_widgets.dart';
import 'community_groups_screen.dart';
import 'manage_members_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({
    super.key,
    required this.community,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityRepository repository;

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late CommunityModel _community;
  List<CommunityMemberModel> _members = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final refreshed = await widget.repository.refreshCommunity(
        _community.id,
        seed: _community,
      );
      final members = await widget.repository.loadMembers(
        _community.id,
        ownerUserId: refreshed?.ownerUserId ?? _community.ownerUserId,
      );
      if (!mounted) return;
      setState(() {
        if (refreshed != null) {
          _community = applyResolvedCommunityCounts(
            model: refreshed.copyWith(
              myRole: refreshed.myRole ?? _community.myRole,
            ),
            seed: _community,
            membersLoaded: members.length,
          );
        } else {
          _community = applyResolvedCommunityCounts(
            model: _community,
            membersLoaded: members.length,
          );
        }
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave({required bool deleteForYou}) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCommunityConfirmDialog(
      context,
      message: deleteForYou
          ? l10n.communityExitAndDeleteConfirm
          : l10n.communityExitConfirm,
    );
    if (confirmed != true || !mounted) return;

    try {
      final userId = readCachedCurrentUserId();
      final canManage = userId != null
          ? _community.canManageFor(userId)
          : _community.canManage;
      if (deleteForYou && canManage) {
        await widget.repository.deleteCommunity(_community.id);
      } else {
        await widget.repository.leaveCommunity(
          _community.id,
          keepSaved: deleteForYou,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, communityLeftRouteResult);
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityTitle = communityDisplayName(_community.name, l10n);
    final description = _community.description ?? '';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: communityTitle,
        topTitle: communityTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppScrollInsets.page(horizontal: 14.w, top: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Center(
                              child: Column(
                                children: [
                                  CommunityAvatar(community: _community, radius: 30),
                                  SizedBox(height: 8.h),
                                  Text(
                                    communityTitle,
                                    style: CommunityStyles.bodySemiBold,
                                  ),
                                  Text(
                                    l10n.communityDetailStats(
                                      _community.groupCount,
                                      _community.memberCount,
                                    ),
                                    style: CommunityStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            if (description.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(description, style: CommunityStyles.caption),
                              ),
                            SizedBox(height: 10.h),
                            _ArrowTile(
                              label: l10n.communityDetailViewGroups,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => CommunityGroupsScreen(
                                    community: _community,
                                    repository: widget.repository,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(l10n.communityDetailViewMembers, style: CommunityStyles.sectionLabel),
                            SizedBox(height: 8.h),
                            ..._members.map((m) => MemberTile(member: m)),
                            SizedBox(height: 10.h),
                            _ArrowTile(
                              label: l10n.communityDetailManageMembers,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ManageMembersScreen(
                                    community: _community,
                                    repository: widget.repository,
                                  ),
                                ),
                              ).then((_) => _load()),
                            ),
                            SizedBox(height: 10.h),
                            GestureDetector(
                              onTap: () => _leave(deleteForYou: false),
                              child: Text(
                                l10n.communityDetailExitCommunity,
                                style: CommunityStyles.destructiveAction,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => _leave(deleteForYou: true),
                              child: Text(
                                l10n.communityDetailExitAndDelete,
                                style: CommunityStyles.destructiveAction,
                              ),
                            ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ArrowTile extends StatelessWidget {
  const _ArrowTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: CommunityStyles.body)),
            Icon(Icons.arrow_forward_ios, size: 16.w),
          ],
        ),
      ),
    );
  }
}
