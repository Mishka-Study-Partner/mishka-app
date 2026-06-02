import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';

import '../../community_styles.dart';
import '../../data/community_current_user.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
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
          _community = refreshed.copyWith(
            myRole: refreshed.myRole ?? _community.myRole,
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
    final confirmed = await showCommunityConfirmDialog(
      context,
      message: deleteForYou
          ? 'Are you sure you want to Exit and delete this community?'
          : 'Are you sure you want to Exit this community?',
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
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e', style: CommunityStyles.snackBar)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = _community.description ?? '';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: _community.name,
        topTitle: _community.name,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            Center(
                              child: Column(
                                children: [
                                  CommunityAvatar(community: _community, radius: 30),
                                  SizedBox(height: 8.h),
                                  Text(
                                    _community.name,
                                    style: CommunityStyles.bodySemiBold,
                                  ),
                                  Text(
                                    'Community : ${_community.groupCount} groups • ${_community.memberCount} Members',
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
                              label: 'View Groups',
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
                            Text('View Members:', style: CommunityStyles.sectionLabel),
                            SizedBox(height: 8.h),
                            ..._members.map((m) => MemberTile(member: m)),
                            SizedBox(height: 10.h),
                            _ArrowTile(
                              label: 'Manage Members',
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
                                'Exit Community',
                                style: CommunityStyles.destructiveAction,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => _leave(deleteForYou: true),
                              child: Text(
                                'Exit And Delete Community (for you)',
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
