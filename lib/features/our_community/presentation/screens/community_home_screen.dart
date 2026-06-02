import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_action_menu.dart';
import '../widgets/community_avatar.dart';
import '../widgets/group_list_item_card.dart';
import 'add_group_screen.dart';
import 'community_detail_screen.dart';
import 'community_group_chat_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({
    super.key,
    required this.community,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityRepository repository;

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  late CommunityModel _community;
  List<CommunityGroupModel> _groups = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final refreshed = await widget.repository.refreshCommunity(
        _community.id,
        seed: _community,
      );
      final groups = await widget.repository.loadChannels(_community.id);
      if (!mounted) return;
      setState(() {
        if (refreshed != null) {
          _community = refreshed.copyWith(
            isMember: true,
            myRole: refreshed.myRole ?? _community.myRole,
            ownerUserId: refreshed.ownerUserId ?? _community.ownerUserId,
          );
        }
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: _community.name,
        topTitle: _community.name,
        showBack: true,
        showBottomBar: false,
      ),
      body: Column(
        children: [
          Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CommunityDetailScreen(
                          community: _community,
                          repository: widget.repository,
                        ),
                      ),
                    ).then((_) => _loadChannels()),
                    leading: CommunityAvatar(community: _community, radius: 28),
                    title: Text(
                      _community.name,
                      style: CommunityStyles.headline,
                    ),
                    subtitle: Text('Community', style: CommunityStyles.caption),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.list,
                        color: AppColors.mainGold,
                        size: 32.w,
                      ),
                      onPressed: () => CommunityActionMenu.show(
                        context,
                        community: _community,
                        repository: widget.repository,
                        onChanged: () => _loadChannels(),
                      ),
                    ),
                  ),
                  Divider(height: 32.h, thickness: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.mainGold,
                      radius: 24.r,
                      child: Icon(Icons.campaign, color: AppColors.white, size: 24.w),
                    ),
                    title: Text(
                      'Announcements',
                      style: CommunityStyles.bodyBold,
                    ),
                    subtitle: Text(
                      _community.description ?? 'Welcome to your community',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CommunityStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(_error!, style: CommunityStyles.error),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadChannels,
                      child: _groups.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 40.h),
                                Center(
                                  child: Text(
                                    'No groups yet. Add your first group.',
                                    style: CommunityStyles.caption,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              itemCount: _groups.length,
                              itemBuilder: (context, index) {
                                final group = _groups[index];
                                return GroupListItemCard(
                                  group: group,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => CommunityGroupChatScreen(
                                        community: _community,
                                        group: group,
                                        repository: widget.repository,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  style: CommunityStyles.goldButtonStyle(),
                  onPressed: () async {
                    await Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (_) => AddGroupScreen(
                          community: _community,
                          repository: widget.repository,
                        ),
                      ),
                    );
                    if (mounted) await _loadChannels();
                  },
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text('Add Group'),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
