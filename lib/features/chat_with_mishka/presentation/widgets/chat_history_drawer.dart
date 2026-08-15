import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/chat_layout_metrics.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/chat_with_mishka/data/models/chat_history_item.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.data,
    required this.isLoading,
    required this.onChatSelected,
    required this.onSessionSelected,
    required this.onNewChat,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final ChatHistoryData data;
  final bool isLoading;
  final ValueChanged<ChatHistoryItem> onChatSelected;
  final ValueChanged<ChatHistoryItem> onSessionSelected;
  final VoidCallback onNewChat;

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String label) {
    if (_query.trim().isEmpty) return true;
    return label.toLowerCase().contains(_query.trim().toLowerCase());
  }

  List<ChatHistoryItem> _filter(List<ChatHistoryItem> items) {
    return items.where((item) => _matches(item.label)).toList();
  }

  void _openSession(ChatHistoryItem item) {
    if (item.opensChatSession) {
      widget.onSessionSelected(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = ChatLayoutMetrics.historyDrawerWidth(context);
    final filteredChats = _filter(widget.data.chats);
    final filteredQuizzes = _filter(widget.data.quizzes);
    final filteredFlashcards = _filter(widget.data.flashcards);
    final filteredSummaries = _filter(widget.data.summaries);
    final filteredMindmaps = _filter(widget.data.mindmaps);

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: widget.isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 280),
          child: IgnorePointer(
            ignoring: !widget.isOpen,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(color: AppColors.mainDark.withValues(alpha: 0.35)),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          left: widget.isOpen ? 0 : -width,
          width: width,
          child: Material(
            elevation: 8,
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: widget.onClose,
                            icon: Icon(
                              Icons.close,
                              size: 26.sp,
                              color: AppColors.mainDark,
                            ),
                          ),
                        ),
                        Text(
                          l10n.yourHistory,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeXXLarge,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeMedium,
                        color: AppColors.mainDark,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchYourHistory,
                        hintStyle: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          color: AppColors.mainGold.withValues(alpha: 0.65),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.mainDark,
                          size: 22.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: AppColors.mainGold,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: AppColors.mainGold,
                            width: 1.4,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: OutlinedButton.icon(
                        onPressed: widget.onNewChat,
                        icon: Icon(
                          Icons.add_comment_outlined,
                          size: 20.sp,
                          color: AppColors.mainGold,
                        ),
                        label: Text(
                          l10n.chatNewChatAction,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: AppSizes.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainGold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.mainGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          backgroundColor: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: widget.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                            children: [
                              _HistorySection(
                                title: l10n.historyChats,
                                items: filteredChats,
                                onItemTap: widget.onChatSelected,
                              ),
                              _HistorySection(
                                title: l10n.historyQuizzes,
                                items: filteredQuizzes,
                                onItemTap: _openSession,
                              ),
                              _HistorySection(
                                title: l10n.historyFlashCards,
                                items: filteredFlashcards,
                                onItemTap: _openSession,
                              ),
                              _HistorySection(
                                title: l10n.historySummarization,
                                items: filteredSummaries,
                                onItemTap: _openSession,
                              ),
                              _HistorySection(
                                title: l10n.historyMindMaps,
                                items: filteredMindmaps,
                                onItemTap: _openSession,
                              ),
                              if (filteredChats.isEmpty &&
                                  filteredQuizzes.isEmpty &&
                                  filteredFlashcards.isEmpty &&
                                  filteredSummaries.isEmpty &&
                                  filteredMindmaps.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 32.h),
                                  child: Text(
                                    l10n.historyEmpty,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Pridi',
                                      fontSize: AppSizes.fontSizeMedium,
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final List<ChatHistoryItem> items;
  final ValueChanged<ChatHistoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeLarge,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 10.h),
          for (final item in items) ...[
            _HistoryRow(
              label: item.label,
              onTap: () => onItemTap(item),
            ),
            SizedBox(height: 8.h),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.h, right: 10.w),
              child: Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mainGold, width: 1.4),
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  color: AppColors.mainDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
