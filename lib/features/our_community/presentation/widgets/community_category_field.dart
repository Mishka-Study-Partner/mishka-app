import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_repository.dart';

/// Optional display category for community create/edit.
class CommunityCategoryField extends StatefulWidget {
  const CommunityCategoryField({
    super.key,
    required this.repository,
    required this.controller,
    this.initialTitles = const [],
  });

  final CommunityRepository repository;
  final TextEditingController controller;
  final List<CommunityCategoryTitle> initialTitles;

  @override
  State<CommunityCategoryField> createState() => _CommunityCategoryFieldState();
}

class _CommunityCategoryFieldState extends State<CommunityCategoryField> {
  List<CommunityCategoryTitle> _suggestions = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _suggestions = widget.initialTitles;
    widget.controller.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSuggestions(widget.controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant CommunityCategoryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTitles != oldWidget.initialTitles &&
        widget.initialTitles.isNotEmpty) {
      setState(() => _suggestions = widget.initialTitles);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onQueryChanged);
    super.dispose();
  }

  void _onQueryChanged() {
    _loadSuggestions(widget.controller.text);
  }

  Future<void> _loadSuggestions(String query) async {
    setState(() => _loading = true);
    try {
      final items = await widget.repository.loadCategoryTitles(
        q: query.trim().isEmpty ? null : query.trim(),
        limit: 30,
      );
      if (!mounted) return;
      setState(() => _suggestions = items);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = widget.controller.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _suggestions
        : _suggestions
            .where((item) => item.title.toLowerCase().contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.communityCreateCategoryLabel,
          style: CommunityStyles.sectionLabel,
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: widget.controller,
          decoration: CommunityStyles.inputDecoration(
            l10n.communityCreateCategoryHint,
          ).copyWith(
            suffixIcon: _loading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          l10n.communityCreateCategoryHelper,
          style: CommunityStyles.caption,
        ),
        if (filtered.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: filtered.take(8).map((item) {
              return ActionChip(
                label: Text(item.title),
                onPressed: () {
                  widget.controller.text = item.title;
                  widget.controller.selection = TextSelection.collapsed(
                    offset: item.title.length,
                  );
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
