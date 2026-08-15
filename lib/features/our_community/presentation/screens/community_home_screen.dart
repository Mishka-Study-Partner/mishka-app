import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_display_helper.dart';
import '../../community_styles.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../../utils/community_navigation.dart';
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

  Future<void> _loadChannels({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final refreshed = await widget.repository.refreshCommunity(
        _community.id,
        seed: _community,
        forceRefresh: forceRefresh,
      );
      if (refreshed != null) {
        _community = applyResolvedCommunityCounts(
          model: refreshed,
          seed: _community,
        );
      }
      if (!_community.isMember) {
        if (!mounted) return;
        setState(() {
          _groups = const [];
          _loading = false;
        });
        return;
      }
      final groups = await widget.repository.loadChannels(_community.id);
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (e is ApiException && (e.statusCode == 403 || e.error == 'FORBIDDEN')) {
        setState(() {
          _community = _community.copyWith(isMember: false);
          _groups = const [];
          _loading = false;
        });
        return;
      }
      setState(() {
        _error = communityErrorMessage(e, l10n: l10n);
        _loading = false;
      });
    }
  }

  Future<void> _joinCommunity() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final joined =
          await widget.repository.joinPublicCommunity(_community.id);
      if (!mounted) return;
      setState(() => _community = joined.copyWith(isMember: true));
      await _loadChannels(forceRefresh: true);
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: l10n),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final communityTitle = communityDisplayName(_community.name, l10n);
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: communityTitle,
        topTitle: communityTitle,
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
                    onTap: () => Navigator.push<Object?>(
                      context,
                      MaterialPageRoute<Object?>(
                        builder: (_) => CommunityDetailScreen(
                          community: _community,
                          repository: widget.repository,
                        ),
                      ),
                    ).then((result) {
                      if (!mounted) return;
                      if (communityRouteLeft(result)) {
                        Navigator.pop(context, communityLeftRouteResult);
                        return;
                      }
                      _loadChannels();
                    }),
                    leading: CommunityAvatar(community: _community, radius: 28),
                    title: Text(
                      communityTitle,
                      style: CommunityStyles.headline,
                    ),
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
                        onChanged: () => _loadChannels(forceRefresh: true),
                        onLeftCommunity: () {
                          if (mounted) {
                            Navigator.pop(context, communityLeftRouteResult);
                          }
                        },
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
                      l10n.communityHomeAnnouncements,
                      style: CommunityStyles.bodyBold,
                    ),
                    subtitle: Text(
                      _community.description ?? l10n.communityHomeWelcomeDefault,
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
              child: !_community.isMember
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.communityAccessDenied,
                              textAlign: TextAlign.center,
                              style: CommunityStyles.caption,
                            ),
                            if (_community.isPublic) ...[
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  style: CommunityStyles.goldButtonStyle(),
                                  onPressed: _joinCommunity,
                                  child: Text(l10n.communityDiscoverJoin),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadChannels,
                      child: _groups.isEmpty
                          ? ListView(
                              padding: AppScrollInsets.list(horizontal: 16.w, top: 10.h),
                              children: [
                                SizedBox(height: 40.h),
                                Center(
                                  child: Text(
                                    l10n.communityHomeNoGroups,
                                    style: CommunityStyles.caption,
                                  ),
                                ),
                                const ScreenEndSpacer(),
                              ],
                            )
                          : ListView.builder(
                              padding: AppScrollInsets.list(horizontal: 16.w, top: 10.h),
                              itemCount: _groups.length,
                              itemBuilder: (context, index) {
                                final group = _groups[index];
                                return GroupListItemCard(
                                  group: group,
                                  onTap: () => Navigator.push<Object?>(
                                    context,
                                    MaterialPageRoute<Object?>(
                                      builder: (_) => CommunityGroupChatScreen(
                                        community: _community,
                                        group: group,
                                        repository: widget.repository,
                                      ),
                                    ),
                                  ).then((result) {
                                    if (!mounted) return;
                                    if (communityRouteLeft(result)) {
                                      Navigator.pop(
                                        context,
                                        communityLeftRouteResult,
                                      );
                                    }
                                  }),
                                );
                              },
                            ),
                    ),
            ),
            if (_community.isMember)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  12.h + AppSizes.screenEndPadding,
                ),
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
                    label: Text(l10n.communityHomeAddGroup),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
