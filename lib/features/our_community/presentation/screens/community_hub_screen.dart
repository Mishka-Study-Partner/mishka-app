import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_locale.dart';
import '../../data/community_models.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_repository.dart';
import '../widgets/community_tile.dart';
import '../widgets/discover_community_tile.dart';
import 'community_discover_screen.dart';
import 'community_home_screen.dart';
import 'create_community_screen.dart';
import '../widgets/community_dialogs.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({
    super.key,
    this.onBack,
    this.scrollToSaved = false,
  });

  final VoidCallback? onBack;
  final bool scrollToSaved;

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _savedSectionKey = GlobalKey();
  final _repository = CommunityRepository();

  bool _loading = true;
  String? _error;
  CommunityHubData _hub = const CommunityHubData();
  List<RecommendedCommunityItem> _recommended = const [];
  bool _didScrollToSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadHub();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSavedSection() {
    if (!widget.scrollToSaved || _didScrollToSaved || !mounted) return;
    _didScrollToSaved = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _savedSectionKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.05,
        );
        return;
      }
      if (_hub.saved.isEmpty) {
        CommunityStyles.showSnackBar(
          context,
          AppLocalizations.of(context)!.communityHubSavedEmptySnack,
        );
      }
    });
  }

  Future<void> _loadHub({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final locale = communityApiLocale();
      final hub = await _repository.loadHub();
      var recommended = const <RecommendedCommunityItem>[];
      try {
        final feed = await _repository.loadRecommended(
          section: 'for_you',
          limit: 8,
          locale: locale,
          forceRefresh: forceRefresh,
        );
        final joinedIds = hub.memberCommunityIds;
        recommended = feed.items
            .where((item) => !joinedIds.contains(item.community.id))
            .toList();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _hub = hub;
        _recommended = recommended;
        _loading = false;
      });
      _scrollToSavedSection();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = communityErrorMessage(
          e,
          l10n: AppLocalizations.of(context)!,
        );
        _loading = false;
      });
    }
  }

  Future<void> _joinRecommended(RecommendedCommunityItem item) async {
    try {
      final joined =
          await _repository.joinPublicCommunity(item.community.id);
      if (!mounted) return;
      _pushHome(joined.copyWith(isMember: true));
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
    }
  }

  Future<void> _openCommunity(CommunityModel community) async {
    if (!community.isMember && community.isPublic) {
      try {
        final joined = await _repository.joinPublicCommunity(community.id);
        if (!mounted) return;
        _pushHome(joined.copyWith(isMember: true));
        return;
      } catch (_) {
        if (!mounted) return;
        CommunityStyles.showSnackBar(
          context,
          AppLocalizations.of(context)!.communityHubJoinFailedOpenAnyway,
        );
      }
    }
    _pushHome(community);
  }

  void _pushHome(CommunityModel community) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CommunityHomeScreen(
          community: community,
          repository: _repository,
        ),
      ),
    ).then((_) => _loadHub());
  }

  Future<void> _joinPrivate() async {
    await showJoinPrivateCommunityDialog(
      context,
      onJoin: (code) => _repository.joinByInviteCode(code),
      onSuccess: (community) {
        _pushHome(community);
        _loadHub();
      },
    );
  }

  List<CommunityModel> _filter(List<CommunityModel> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.subtitle.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saved = _filter(_hub.saved);
    final private = _filter(_hub.privateCommunities);
    final public = _filter(_hub.publicCommunities);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.ourCommunity,
        topTitle: l10n.ourCommunity,
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadHub(forceRefresh: true),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: CommunityStyles.error,
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: _loadHub,
                        child: Text(l10n.retry),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: CommunityStyles.inputDecoration(
                        l10n.communityHubSearchHint,
                      ).copyWith(
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _MainButton(
                      label: l10n.communityHubCreateNew,
                      onTap: () async {
                        await Navigator.push<bool>(
                          context,
                          MaterialPageRoute<bool>(
                            builder: (_) => CreateCommunityScreen(
                              repository: _repository,
                            ),
                          ),
                        );
                        if (mounted) await _loadHub();
                      },
                    ),
                    SizedBox(height: 8.h),
                    _MainButton(
                      label: l10n.communityHubJoinPrivate,
                      onTap: _joinPrivate,
                    ),
                    SizedBox(height: 16.h),
                    _Section(
                      key: _savedSectionKey,
                      title: l10n.communityHubSavedSection,
                      communities: saved,
                      onTap: _openCommunity,
                      showWhenEmpty: widget.scrollToSaved,
                      emptyMessage: l10n.communityHubSavedEmpty,
                    ),
                    SizedBox(height: 16.h),
                    _Section(
                      title: l10n.communityHubPrivateSection,
                      communities: private,
                      onTap: _openCommunity,
                    ),
                    SizedBox(height: 16.h),
                    _Section(
                      title: l10n.communityHubPublicSection,
                      communities: public,
                      onTap: _openCommunity,
                    ),
                    if (_recommended.isEmpty &&
                        !_loading &&
                        _error == null &&
                        (public.isNotEmpty || private.isNotEmpty)) ...[
                      SizedBox(height: 16.h),
                      Text(
                        l10n.communityHubRecommendedSection,
                        style: CommunityStyles.sectionLabel,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.communityHubRecommendedEmpty,
                        style: CommunityStyles.caption,
                      ),
                    ],
                    if (_recommended.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.communityHubRecommendedSection,
                            style: CommunityStyles.sectionLabel,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => CommunityDiscoverScreen(
                                    repository: _repository,
                                  ),
                                ),
                              ).then((_) => _loadHub());
                            },
                            child: Text(
                              l10n.communityHubSeeAll,
                              style: CommunityStyles.caption.copyWith(
                                color: AppColors.mainGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 100.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommended.length,
                          itemBuilder: (context, index) {
                            final item = _recommended[index];
                            return DiscoverCommunityTile(
                              compact: true,
                              card: item.community,
                              subtitle: item.matchReason.isNotEmpty
                                  ? item.matchReason
                                  : null,
                              joinLabel: l10n.communityDiscoverJoin,
                              onTap: () => _joinRecommended(item),
                              onJoin: () => _joinRecommended(item),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    _MainButton(
                      label: l10n.communityHubDiscoverButton,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CommunityDiscoverScreen(
                              repository: _repository,
                            ),
                          ),
                        ).then((_) => _loadHub());
                      },
                    ),
                    if (!_loading &&
                        _error == null &&
                        saved.isEmpty &&
                        private.isEmpty &&
                        public.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Center(
                          child: Text(
                            l10n.communityHubEmpty,
                            textAlign: TextAlign.center,
                            style: CommunityStyles.caption,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: CommunityStyles.goldButtonStyle(),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.title,
    required this.communities,
    required this.onTap,
    this.showWhenEmpty = false,
    this.emptyMessage,
  });

  final String title;
  final List<CommunityModel> communities;
  final ValueChanged<CommunityModel> onTap;
  final bool showWhenEmpty;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (communities.isEmpty && !showWhenEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CommunityStyles.sectionLabel),
        SizedBox(height: 8.h),
        if (communities.isEmpty)
          Text(
            emptyMessage ?? AppLocalizations.of(context)!.communityHubNoneYet,
            style: CommunityStyles.caption,
          )
        else
          ...communities.map(
            (c) => CommunityTile(
              community: c,
              onTap: () => onTap(c),
            ),
          ),
      ],
    );
  }
}
