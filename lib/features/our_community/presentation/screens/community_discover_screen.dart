import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_locale.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_repository.dart';
import '../widgets/discover_community_tile.dart';
import 'community_home_screen.dart';

class CommunityDiscoverScreen extends StatefulWidget {
  const CommunityDiscoverScreen({
    super.key,
    this.repository,
    this.initialSection = 'for_you',
  });

  final CommunityRepository? repository;
  final String initialSection;

  @override
  State<CommunityDiscoverScreen> createState() =>
      _CommunityDiscoverScreenState();
}

class _CommunityDiscoverScreenState extends State<CommunityDiscoverScreen> {
  late final CommunityRepository _repository =
      widget.repository ?? CommunityRepository();

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late String _section;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _browseMode = false;
  String? _subjectFilter;
  RecommendedFeed? _recommended;
  DiscoverCategories? _categories;
  DiscoverBrowsePage? _browse;
  final List<CommunityDiscoverCard> _browseItems = [];

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_browseMode || _loadingMore || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;
    final page = _browse;
    if (page == null || !page.hasMore) return;
    _loadBrowse(append: true);
  }

  List<(String, String)> _sections(AppLocalizations l10n) => [
        ('for_you', l10n.communityDiscoverForYou),
        ('popular', l10n.communityDiscoverPopular),
        ('new', l10n.communityDiscoverNew),
      ];

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final locale = communityApiLocale(context);
      _categories ??= await _repository.loadDiscoverCategories(locale: locale);
      if (_browseMode || _searchController.text.trim().isNotEmpty) {
        await _loadBrowse();
      } else {
        final feed = await _repository.loadRecommended(
          section: _section,
          limit: 30,
          locale: locale,
          forceRefresh: forceRefresh,
        );
        if (!mounted) return;
        setState(() {
          _recommended = feed;
          _loading = false;
        });
      }
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

  Future<void> _loadBrowse({bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _browseItems.clear();
      });
    }

    try {
      final locale = communityApiLocale(context);
      final offset = append ? _browseItems.length : 0;
      final page = await _repository.browseDiscover(
        subject: _subjectFilter,
        q: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        limit: 20,
        offset: offset,
        locale: locale,
      );
      if (!mounted) return;
      setState(() {
        _browse = page;
        if (append) {
          _browseItems.addAll(page.items);
        } else {
          _browseItems
            ..clear()
            ..addAll(page.items);
        }
        _browseMode = true;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = communityErrorMessage(
          e,
          l10n: AppLocalizations.of(context)!,
        );
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _join(CommunityDiscoverCard card) async {
    try {
      final joined = await _repository.joinPublicCommunity(card.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CommunityHomeScreen(
            community: joined.copyWith(isMember: true),
            repository: _repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
    }
  }

  void _selectSection(String section) {
    if (_section == section && !_browseMode) return;
    setState(() {
      _section = section;
      _browseMode = false;
      _subjectFilter = null;
      _recommended = null;
    });
    _load();
  }

  void _applySubjectFilter(String? key) {
    setState(() {
      _subjectFilter = key;
      _browseMode = true;
      _recommended = null;
    });
    _loadBrowse();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _sections(l10n);
    final subjects = (_categories?.subjects ?? [])
        .where((c) => c.communityCount > 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.communityDiscoverTitle,
        topTitle: l10n.communityDiscoverTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: CommunityStyles.inputDecoration(
                        l10n.communityDiscoverSearchHint,
                      )
                          .copyWith(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _browseMode = false;
                                  });
                                  _load();
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) {
                        setState(() => _browseMode = true);
                        _loadBrowse();
                      },
                    ),
                    SizedBox(height: 12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sections
                            .map(
                              (entry) => Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(entry.$2),
                                  selected: !_browseMode && _section == entry.$1,
                                  onSelected: (_) => _selectSection(entry.$1),
                                  selectedColor: AppColors.mainGold.withValues(alpha: 0.25),
                                  labelStyle: CommunityStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: !_browseMode && _section == entry.$1
                                        ? AppColors.mainDark
                                        : AppColors.lightText,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (subjects.isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Text(
                        l10n.communityDiscoverSubjects,
                        style: CommunityStyles.sectionLabel,
                      ),
                      SizedBox(height: 6.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text(l10n.communityDiscoverAll),
                              selected: _subjectFilter == null && _browseMode,
                              onSelected: (_) {
                                setState(() {
                                  _subjectFilter = null;
                                  _browseMode = false;
                                });
                                _load();
                              },
                            ),
                            ...subjects.map(
                              (chip) => Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: FilterChip(
                                  label: Text(chip.label),
                                  selected: _subjectFilter == chip.key,
                                  onSelected: (_) => _applySubjectFilter(chip.key),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      SizedBox(height: 12.h),
                      Text(_error!, style: CommunityStyles.error),
                      TextButton(onPressed: _load, child: Text(l10n.retry)),
                    ],
                    if (_recommended?.needsProfileEducation == true) ...[
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.mainGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.mainGold),
                        ),
                        child: Text(
                          l10n.communityDiscoverProfileHint,
                          style: CommunityStyles.caption,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_browseMode)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _browseItems.length) {
                      return _loadingMore
                          ? Padding(
                              padding: EdgeInsets.all(16.h),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    final card = _browseItems[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: DiscoverCommunityTile(
                        card: card,
                        onTap: () => _join(card),
                        joinLabel: l10n.communityDiscoverJoin,
                        onJoin: () => _join(card),
                      ),
                    );
                  },
                  childCount: _browseItems.length + (_loadingMore ? 1 : 0),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final items = _recommended?.items ?? const [];
                    if (items.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Center(
                          child: Text(
                            l10n.communityDiscoverEmpty,
                            style: CommunityStyles.caption,
                          ),
                        ),
                      );
                    }
                    final item = items[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: DiscoverCommunityTile(
                        card: item.community,
                        subtitle: item.matchReason.isNotEmpty
                            ? item.matchReason
                            : null,
                        onTap: () => _join(item.community),
                        joinLabel: l10n.communityDiscoverJoin,
                        onJoin: () => _join(item.community),
                      ),
                    );
                  },
                  childCount: (_recommended?.items.isEmpty ?? true)
                      ? 1
                      : _recommended!.items.length,
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
