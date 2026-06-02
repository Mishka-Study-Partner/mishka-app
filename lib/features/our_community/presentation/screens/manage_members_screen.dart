import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_current_user.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_dialogs.dart';
import '../widgets/member_widgets.dart';
import 'select_group_for_member_screen.dart';

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({
    super.key,
    required this.community,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityRepository repository;

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  int? _expandedIndex;
  List<CommunityMemberModel> _members = const [];
  bool _loading = true;

  bool get _canManage {
    final userId = readCachedCurrentUserId();
    if (userId != null) return widget.community.canManageFor(userId);
    return widget.community.canManage;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final members = await widget.repository.loadMembers(widget.community.id);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setRole(CommunityMemberModel member, String role) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.repository.setMemberRole(
        widget.community.id,
        member.userId,
        role: role,
      );
      if (!mounted) return;
      await showCommunitySuccessDialog(
        context,
        message: l10n.communityMemberRoleUpdated,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(communityErrorMessage(e), style: CommunityStyles.snackBar),
        ),
      );
    }
  }

  bool _canChangeRoleFor(CommunityMemberModel member) {
    if (!_canManage) return false;
    if (member.role == 'Owner') return false;
    final selfId = readCachedCurrentUserId();
    if (selfId != null && selfId == member.userId) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: "${widget.community.name} Members",
        topTitle: "${widget.community.name} Members",
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _members.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 48.h),
                        Center(
                          child: Text(
                            l10n.communityDiscoverEmpty,
                            style: CommunityStyles.caption,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(12.w),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        final canChange = _canChangeRoleFor(member);
                        return ManageMemberCard(
                          member: member,
                          expanded: _expandedIndex == index,
                          onExpand: () => setState(() {
                            _expandedIndex =
                                _expandedIndex == index ? null : index;
                          }),
                          canChangeRole: canChange,
                          promoteLabel: l10n.communityMemberPromoteAdmin,
                          demoteLabel: l10n.communityMemberDemoteMember,
                          onPromoteToAdmin: canChange
                              ? () => _setRole(member, 'admin')
                              : null,
                          onDemoteToMember: canChange
                              ? () => _setRole(member, 'member')
                              : null,
                          onAddToGroup: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => SelectGroupForMemberScreen(
                                community: widget.community,
                                memberName: member.name,
                                repository: widget.repository,
                              ),
                            ),
                          ),
                          onRemoveFromCommunity: () async {
                            final confirmed = await showCommunityConfirmDialog(
                              context,
                              message:
                                  'Are you sure you want to remove this member from the community?',
                            );
                            if (!context.mounted || confirmed != true) return;
                            try {
                              await widget.repository.removeMember(
                                widget.community.id,
                                member.userId,
                              );
                              if (!context.mounted) return;
                              await showCommunitySuccessDialog(
                                context,
                                message: 'Member removed from community.',
                              );
                              await _load();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    communityErrorMessage(e),
                                    style: CommunityStyles.snackBar,
                                  ),
                                ),
                              );
                            }
                          },
                          onRemoveFromGroup: (_) async {
                            final confirmed = await showCommunityConfirmDialog(
                              context,
                              message: 'Remove member from group?',
                            );
                            if (!context.mounted || confirmed != true) return;
                            await showCommunitySuccessDialog(
                              context,
                              message: 'Member removed from group.',
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
