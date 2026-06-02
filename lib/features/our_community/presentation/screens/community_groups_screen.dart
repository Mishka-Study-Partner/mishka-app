import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_current_user.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_dialogs.dart';
import 'add_group_screen.dart';

class CommunityGroupsScreen extends StatefulWidget {
  const CommunityGroupsScreen({
    super.key,
    required this.community,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityRepository repository;

  @override
  State<CommunityGroupsScreen> createState() => _CommunityGroupsScreenState();
}

class _CommunityGroupsScreenState extends State<CommunityGroupsScreen> {
  int _expandedIndex = -1;
  List<CommunityGroupModel> _groups = const [];
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
      final groups = await widget.repository.loadChannels(widget.community.id);
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinGroup(CommunityGroupModel group) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCommunityConfirmDialog(
      context,
      message: l10n.communityConfirmJoinGroup,
    );
    if (confirmed != true) return;
    try {
      await widget.repository.joinChannel(widget.community.id, group.id);
      if (!mounted) return;
      await showCommunitySuccessDialog(
        context,
        message: l10n.communityJoinedGroupSuccess,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
    }
  }

  Future<void> _deleteGroup(CommunityGroupModel group) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCommunityConfirmDialog(
      context,
      message: l10n.communityConfirmDeleteGroup,
    );
    if (confirmed != true) return;
    try {
      await widget.repository.deleteChannel(widget.community.id, group.id);
      if (!mounted) return;
      await _load();
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
    final communityTitle =
        communityDisplayName(widget.community.name, l10n);
    final groupsTitle = l10n.communityGroupsTitle(communityTitle);
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: groupsTitle,
        topTitle: groupsTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _groups.length,
                        itemBuilder: (context, index) {
                                  final group = _groups[index];
                                  final isExpanded = _expandedIndex == index;

                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _expandedIndex =
                                              isExpanded ? -1 : index;
                                        }),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 6.h),
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Row(
                                            children: [
                                              GroupAvatar(group: group),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      communityGroupDisplayName(
                                                        group.name,
                                                        l10n,
                                                      ),
                                                      style: CommunityStyles.body,
                                                    ),
                                                    Text(group.memberLabel, style: CommunityStyles.caption),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                isExpanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10.h),
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Column(
                                            children: [
                                              if (!group.joined)
                                                _OutlineActionButton(
                                                  label: l10n.communityGroupJoin,
                                                  color: AppColors.green,
                                                  onTap: () => _joinGroup(group),
                                                ),
                                              if (!group.joined) SizedBox(height: 8.h),
                                              if (_canManage)
                                                _OutlineActionButton(
                                                  label: l10n.communityGroupDelete,
                                                  color: AppColors.red,
                                                  onTap: () => _deleteGroup(group),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                        },
                      ),
                    ),
                  ),
                  if (_canManage)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: CommunityStyles.goldButtonStyle(),
                        onPressed: () async {
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (_) => AddGroupScreen(
                                community: widget.community,
                                repository: widget.repository,
                              ),
                            ),
                          );
                          if (mounted) await _load();
                        },
                        child: Text(l10n.communityGroupAddNew),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: CommunityStyles.outlineAction(color),
        ),
      ),
    );
  }
}
