import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../../../core/utils/app_colors.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_cache.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/quiz_result_screen.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/flashcards_result_screen.dart';
import 'package:mishka_app/features/saved/data/models/quiz_submit_outcome.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import '../../data/tool_data_normalizer.dart';
import 'formatted_study_text.dart';
import 'study_text_utils.dart';

enum ToolPreviewLayout { embedded, expanded, saved, communityChat }

class ToolPreviewRenderer extends StatefulWidget {
  final Map<String, dynamic> toolData;
  final bool embedded;
  final ToolPreviewLayout layout;
  final ValueChanged<Map<String, dynamic>>? onToolDataUpdated;
  final String? storageMessageId;
  final int? previousScorePercent;
  final ValueChanged<int?>? onPreviousScoreChanged;
  final Future<QuizSubmitOutcome?> Function({
    required List<Map<String, dynamic>> questions,
    required Map<int, int> selectedAnswers,
  })? onSubmitSavedQuiz;

  const ToolPreviewRenderer({
    super.key,
    required this.toolData,
    this.embedded = false,
    this.layout = ToolPreviewLayout.embedded,
    this.onToolDataUpdated,
    this.storageMessageId,
    this.previousScorePercent,
    this.onPreviousScoreChanged,
    this.onSubmitSavedQuiz,
  });

  @override
  State<ToolPreviewRenderer> createState() => _ToolPreviewRendererState();
}

class _ToolPreviewRendererState extends State<ToolPreviewRenderer> {
  int currentQuestionIndex = 0;
  int currentFlashcardIndex = 0;
  int? selectedAnswerIndex;
  bool answered = false;
  bool showQuizResults = false;
  final Map<int, int> selectedAnswers = {};
  final Map<int, bool> questionCorrect = {};
  Map<int, bool> flashcardFlipped = {};
  bool _savedQuizRetaking = false;
  int? _savedQuizPreviousScore;

  bool get _isCommunityChat => widget.layout == ToolPreviewLayout.communityChat;

  bool get _isExpandedQuiz => widget.layout == ToolPreviewLayout.expanded;
  bool get _isSavedQuiz => widget.layout == ToolPreviewLayout.saved;
  bool get _isExpandedFlashcards =>
      widget.layout == ToolPreviewLayout.expanded;
  bool get _isSavedFlashcards => widget.layout == ToolPreviewLayout.saved;
  bool get _isExpandedMindMap => widget.layout == ToolPreviewLayout.expanded;
  bool get _isSavedMindMap =>
      widget.layout == ToolPreviewLayout.saved &&
      widget.toolData['tool_type']?.toString() == 'mind_maps';

  _QuizTheme get _quizTheme {
    if (_isSavedQuiz) return _QuizTheme.saved;
    return _isExpandedQuiz ? _QuizTheme.expanded : _QuizTheme.embedded;
  }

  @override
  void initState() {
    super.initState();
    _savedQuizPreviousScore = widget.previousScorePercent;
    _hydrateQuizProgressFromToolData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ToolPreviewRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toolData != widget.toolData ||
        oldWidget.previousScorePercent != widget.previousScorePercent) {
      _savedQuizPreviousScore =
          widget.previousScorePercent ?? _savedQuizPreviousScore;
      _hydrateQuizProgressFromToolData();
    }
  }

  void _hydrateQuizProgressFromToolData() {
    final data = QuizProgressCache.mergeStoredProgress(
      normalizeToolData(widget.toolData),
      widget.storageMessageId,
    );
    final progress = readQuizProgress(data);
    _savedQuizPreviousScore =
        widget.previousScorePercent ?? progress?.percent ?? _savedQuizPreviousScore;

    if (progress == null) {
      _resetLocalQuizState();
      _savedQuizRetaking = false;
      return;
    }

    if (_isSavedQuiz && progress.completed && !_savedQuizRetaking) {
      _savedQuizPreviousScore = progress.percent ?? _savedQuizPreviousScore;
      _resetLocalQuizState();
      return;
    }

    currentQuestionIndex = progress.currentQuestionIndex;
    selectedAnswers
      ..clear()
      ..addAll(progress.selectedAnswers);
    questionCorrect
      ..clear()
      ..addAll(progress.questionCorrect);
    showQuizResults = progress.showResults || progress.completed;
    _restoreQuestionState(currentQuestionIndex);
  }

  void _startSavedQuizRetake() {
    _savedQuizRetaking = true;
    _resetLocalQuizState();
    final cleared = clearQuizProgress(widget.toolData);
    widget.onToolDataUpdated?.call(cleared);
    final messageId = widget.storageMessageId;
    if (messageId != null && messageId.isNotEmpty) {
      unawaited(QuizProgressCache.clear(messageId));
    }
    setState(() {});
  }

  void _resetLocalQuizState() {
    currentQuestionIndex = 0;
    selectedAnswerIndex = null;
    answered = false;
    showQuizResults = false;
    selectedAnswers.clear();
    questionCorrect.clear();
  }

  QuizProgressSnapshot _currentQuizProgress({
    bool? showResults,
    bool? completed,
    int? percent,
  }) {
    return QuizProgressSnapshot(
      currentQuestionIndex: currentQuestionIndex,
      selectedAnswers: Map<int, int>.from(selectedAnswers),
      questionCorrect: Map<int, bool>.from(questionCorrect),
      showResults: showResults ?? showQuizResults,
      completed: completed ?? showQuizResults,
      percent: percent,
    );
  }

  void _persistQuizProgress({
    bool? showResults,
    bool? completed,
    int? percent,
  }) {
    if (widget.onToolDataUpdated == null || !isQuizToolData(widget.toolData)) {
      return;
    }
    final updated = applyQuizProgress(
      toolData: widget.toolData,
      progress: _currentQuizProgress(
        showResults: showResults,
        completed: completed,
        percent: percent,
      ),
    );
    final messageId = widget.storageMessageId;
    if (messageId != null && messageId.isNotEmpty) {
      unawaited(
        QuizProgressCache.write(
          messageId,
          readQuizProgress(updated) ?? _currentQuizProgress(
            showResults: showResults,
            completed: completed,
            percent: percent,
          ),
        ),
      );
    }
    widget.onToolDataUpdated!(updated);
  }

  @override
  Widget build(BuildContext context) {
    final data = normalizeToolData(widget.toolData);
    final toolType = data['tool_type'] ?? 'unknown';

    final content = switch (toolType) {
        'flashcards' => _buildFlashcardsPreview(data),
        'quiz' => _buildQuizPreview(data),
        'quizzes' => _buildQuizPreview(data),
        'mind_maps' => _buildMindmapPreview(data),
        'mindmap' => _buildMindmapPreview(data),
        'summary' => _buildSummaryPreview(data),
        'summarize' => _buildSummaryPreview(data),
        'summaries' => _buildSummaryPreview(data),
        _ => _buildUnknownToolPreview(data),
      };

    if (widget.embedded) return content;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: content,
    );
  }

  Widget _buildUnknownToolPreview(Map<String, dynamic> data) {
    final inferred = (data['tool_type'] ?? '').toString();
    if (inferred.contains('summ') ||
        data['summaryText'] != null ||
        data['explanation'] != null) {
      return _buildSummaryFallbackPreview(data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSummaryFallbackPreview(Map<String, dynamic> data) {
    final text = (data['summaryText'] ??
            data['explanation'] ??
            data['summary'] ??
            data['text'] ??
            (data['content'] is String ? data['content'] : null) ??
            '')
        .toString()
        .trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return _buildSummaryPreviewBody(data, text);
  }

  Widget _buildSummaryPreview(Map<String, dynamic> data) {
    final text = (data['summaryText'] ??
            data['explanation'] ??
            data['summary'] ??
            data['text'] ??
            (data['content'] is String ? data['content'] : null) ??
            '')
        .toString()
        .trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return _buildSummaryPreviewBody(data, text);
  }

  Widget _buildSummaryPreviewBody(Map<String, dynamic> data, String text) {
    final body = FormattedStudyText(
      text: text,
      textAlign: TextAlign.justify,
      baseStyle: TextStyle(
        fontSize: ToolFocusMetrics.chromeBodySize(context),
        height: 1.45,
        color: AppColors.mainDark,
        fontFamily: 'Pridi',
      ),
    );

    if (widget.layout != ToolPreviewLayout.embedded &&
        widget.layout != ToolPreviewLayout.communityChat) {
      return body;
    }

    final maxHeight = _isCommunityChat
        ? ToolFocusMetrics.communityEmbeddedSummaryMaxHeight(context)
        : ToolFocusMetrics.embeddedSummaryMaxHeight(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(child: body),
    );
  }

  // ===========================
  // FLASHCARDS PREVIEW
  // ===========================
  Widget _buildFlashcardsPreview(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final cards = data['cards'] as List<dynamic>? ?? [];

    if (cards.isEmpty) {
      return _buildEmptyState();
    }

    if (currentFlashcardIndex >= cards.length) {
      currentFlashcardIndex = cards.length - 1;
    }
    if (currentFlashcardIndex < 0) currentFlashcardIndex = 0;

    final card = cards[currentFlashcardIndex] as Map<String, dynamic>;
    final isLastCard = currentFlashcardIndex >= cards.length - 1;
    final footer = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        Text(
          l10n.flashcardProgress(currentFlashcardIndex + 1, cards.length),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: ToolFocusMetrics.progressLabelSize(context),
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        Row(
          children: [
            _FlashcardNavButton(
              label: l10n.back,
              filled: false,
              enabled: currentFlashcardIndex > 0,
              onTap: currentFlashcardIndex > 0
                  ? () => setState(() => currentFlashcardIndex--)
                  : null,
            ),
            const Spacer(),
            _FlashcardNavButton(
              label: isLastCard ? l10n.done : l10n.next,
              filled: true,
              enabled: true,
              onTap: isLastCard
                  ? () => _finishFlashcards(cards.length)
                  : () => setState(() => currentFlashcardIndex++),
            ),
          ],
        ),
      ],
    );

    if (_isExpandedFlashcards || _isSavedFlashcards) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildFlashcardItem(card, currentFlashcardIndex),
          ),
          footer,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _isCommunityChat
              ? ToolFocusMetrics.communityEmbeddedFlashcardHeight(context)
              : ToolFocusMetrics.embeddedFlashcardHeight(context),
          child: _buildFlashcardItem(card, currentFlashcardIndex),
        ),
        footer,
      ],
    );
  }

  Widget _buildFlashcardItem(Map<String, dynamic> card, int index) {
    final isFlipped = flashcardFlipped[index] ?? false;
    final isLargeLayout = _isExpandedFlashcards || _isSavedFlashcards;
    final cardPadding = isLargeLayout ? 12.r : 8.r;
    final iconContainerSize = ToolFocusMetrics.flashcardIconContainerSize(
      context,
      large: isLargeLayout,
    );
    final placeholderIconSize = ToolFocusMetrics.flashcardPlaceholderIconSize(
      context,
      large: isLargeLayout,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          flashcardFlipped[index] = !isFlipped;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<bool>(isFlipped),
          width: double.infinity,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.mainGold, width: 1.5),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: isLargeLayout ? 14.h : 10.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: _FlashcardIconBadge(
                      imagePath: card['image'] as String?,
                      containerSize: iconContainerSize,
                      iconSize: placeholderIconSize,
                    ),
                  ),
                ),
                SizedBox(height: isLargeLayout ? 12.h : 8.h),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: StudyText(
                        isFlipped
                            ? (card['back'] as String? ?? 'Answer')
                            : (card['front'] as String? ??
                                card['title'] as String? ??
                                'Card'),
                        style: TextStyle(
                          fontSize: ToolFocusMetrics.flashcardCardTextSize(
                            context,
                            large: isLargeLayout,
                          ),
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainDark,
                          fontFamily: 'Pridi',
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================
  // QUIZ PREVIEW
  // ===========================
  Widget _buildQuizPreview(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final questions = data['questions'] as List<dynamic>? ?? [];
    final total = data['totalQuestions'] as int? ?? questions.length;

    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    if (showQuizResults && !_isExpandedQuiz && !_isSavedQuiz) {
      return _buildQuizScoreSummary(questions);
    }

    final question = questions[currentQuestionIndex] as Map<String, dynamic>;
    final options = List<String>.from(question['options'] as List<dynamic>? ?? []);
    final correctIndex = question['correctOptionIndex'] as int? ?? -1;
    final questionText = question['questionText'] as String? ?? 'Question?';
    final theme = _quizTheme;

    final correctCount = questionCorrect.values.where((ok) => ok).length;
    final wrongCount = questionCorrect.values.where((ok) => !ok).length;
    final progressValue =
        total == 0 ? 0.0 : (currentQuestionIndex + 1) / total;

    final quizBody = _buildQuizQuestionBody(
      options: options,
      correctIndex: correctIndex,
      questionText: questionText,
      theme: theme,
      total: total,
    );

    if (!_isSavedQuiz) {
      return quizBody;
    }

    final previousScore = _savedQuizPreviousScore;
    final showPreviousScore = previousScore != null && !_savedQuizRetaking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPreviousScore) ...[
          _buildSavedQuizPreviousScoreCard(l10n, previousScore),
          SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 3.h,
            backgroundColor: AppColors.mainGold.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mainGold),
          ),
        ),
        SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        Row(
          children: [
            Text(
              l10n.savedQuizQuestionLabel(currentQuestionIndex + 1, total),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: ToolFocusMetrics.progressLabelSize(context),
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
            const Spacer(),
            Text(
              l10n.savedQuizCorrectWrong(correctCount, wrongCount),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: ToolFocusMetrics.progressLabelSize(context),
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
          ],
        ),
        SizedBox(height: ToolFocusMetrics.sectionGap(context)),
        Expanded(child: quizBody),
        SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        _buildSavedQuizFooter(l10n, correctIndex, theme),
        SizedBox(height: ToolFocusMetrics.chromeGap(context)),
        Row(
          children: [
            _SavedQuizNavButton(
              label: l10n.back,
              filled: false,
              enabled: currentQuestionIndex > 0,
              onTap: currentQuestionIndex > 0 ? _previousQuestion : null,
              theme: theme,
            ),
            const Spacer(),
            if (currentQuestionIndex < questions.length - 1)
              _SavedQuizNavButton(
                label: l10n.next,
                filled: true,
                enabled: answered,
                onTap: answered ? _nextQuestion : null,
                theme: theme,
              )
            else
              _SavedQuizNavButton(
                label: l10n.done,
                filled: true,
                enabled: answered,
                onTap: answered ? () => _finishQuiz(questions) : null,
                theme: theme,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizQuestionBody({
    required List<String> options,
    required int correctIndex,
    required String questionText,
    required _QuizTheme theme,
    required int total,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (_isSavedQuiz) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                10.w,
                ToolFocusMetrics.chromeGap(context) + 2.h,
                10.w,
                ToolFocusMetrics.chromeGap(context) + 2.h,
              ),
              color: AppColors.mainGold,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StudyText(
                      questionText,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: ToolFocusMetrics.chromeBodySize(context),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.quizProgress(currentQuestionIndex + 1, total),
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: ToolFocusMetrics.progressLabelSize(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                child: _buildQuizOptionsList(
                  options: options,
                  correctIndex: correctIndex,
                  theme: theme,
                  numbered: true,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StudyText(
                questionText,
                style: TextStyle(
                  fontSize: theme.questionSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                  fontFamily: 'Pridi',
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(width: theme.gapMedium),
            Text(
              l10n.quizProgress(currentQuestionIndex + 1, total),
              style: TextStyle(
                fontSize: theme.progressSize,
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
                fontFamily: 'Pridi',
              ),
            ),
          ],
        ),
        SizedBox(height: theme.gapLarge),
        _buildQuizOptionsList(
          options: options,
          correctIndex: correctIndex,
          theme: theme,
          numbered: false,
        ),
        if (answered && !_isSavedQuiz) ...[
          SizedBox(height: theme.gapLarge),
          Row(
            children: [
              if (currentQuestionIndex > 0)
                _QuizNavButton(
                  label: l10n.back,
                  onTap: _previousQuestion,
                  theme: theme,
                ),
              const Spacer(),
              if (currentQuestionIndex < total - 1)
                _QuizNavButton(
                  label: l10n.next,
                  onTap: _nextQuestion,
                  theme: theme,
                )
              else
                _QuizNavButton(
                  label: l10n.done,
                  onTap: () => _finishQuiz(
                    normalizeToolData(widget.toolData)['questions']
                            as List<dynamic>? ??
                        const [],
                  ),
                  theme: theme,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuizOptionsList({
    required List<String> options,
    required int correctIndex,
    required _QuizTheme theme,
    required bool numbered,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: List.generate(options.length, (optIndex) {
            final isSelected = selectedAnswerIndex == optIndex;
            final isCorrect = optIndex == correctIndex;
            final showResult = answered && isSelected;

            Color bgColor = Colors.white;
            Color borderColor = AppColors.stroke;
            Color? labelColor;
            String? resultLabel;

            if (showResult) {
              if (isCorrect) {
                bgColor = const Color(0xFFE8F5E9);
                borderColor = AppColors.green;
                labelColor = AppColors.green;
                resultLabel = l10n.correctAnswer;
              } else {
                bgColor = const Color(0xFFFFEBEE);
                borderColor = AppColors.red;
                labelColor = AppColors.red;
                resultLabel = l10n.wrongAnswer;
              }
            } else if (answered && _isSavedQuiz && optIndex == correctIndex) {
              bgColor = const Color(0xFFE8F5E9);
              borderColor = AppColors.green;
            }

            return GestureDetector(
              onTap: !answered
                  ? () {
                      setState(() {
                        selectedAnswerIndex = optIndex;
                        answered = true;
                        selectedAnswers[currentQuestionIndex] = optIndex;
                        questionCorrect[currentQuestionIndex] =
                            optIndex == correctIndex;
                      });
                      _persistQuizProgress();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.optionHorizontalPadding,
                  vertical: theme.optionVerticalPadding,
                ),
                margin: EdgeInsets.only(bottom: theme.optionSpacing),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.optionRadius),
                  border: Border.all(color: borderColor),
                  color: bgColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!answered)
                      Container(
                        width: theme.radioSize,
                        height: theme.radioSize,
                        margin: EdgeInsets.only(
                          right: theme.gapMedium,
                          top: theme.radioTopInset,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.mainDark
                                : AppColors.greyText,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: theme.radioDotSize,
                                  height: theme.radioDotSize,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.mainDark,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    if (numbered) ...[
                      Text(
                        '${optIndex + 1}.',
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: theme.optionTextSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainDark,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (resultLabel != null && !_isSavedQuiz)
                            Padding(
                              padding: EdgeInsets.only(bottom: theme.gapSmall),
                              child: Text(
                                resultLabel,
                                style: TextStyle(
                                  fontSize: theme.resultLabelSize,
                                  fontWeight: FontWeight.w600,
                                  color: labelColor,
                                  fontFamily: 'Pridi',
                                ),
                              ),
                            ),
                          StudyText(
                            options[optIndex],
                            style: TextStyle(
                              fontSize: theme.optionTextSize,
                              color: AppColors.mainDark,
                              fontFamily: 'Pridi',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (answered && !_isSavedQuiz)
          Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: selectedAnswerIndex == correctIndex
                  ? _buildHappyCat(theme)
                  : _buildSadCat(theme),
            ),
          ),
      ],
    );
  }

  Widget _buildSavedQuizPreviousScoreCard(AppLocalizations l10n, int percent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.mainGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.savedQuizPreviousScore(percent),
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: ToolFocusMetrics.chromeBodySize(context),
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startSavedQuizRetake,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGold,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                l10n.savedQuizSolveAgain,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: ToolFocusMetrics.navButtonFontSize(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedQuizFooter(AppLocalizations l10n, int correctIndex, _QuizTheme theme) {
    String feedback;
    Color feedbackColor = AppColors.mainDark;

    if (!answered) {
      feedback = l10n.focusBeforeAnswering;
    } else if (selectedAnswerIndex == correctIndex) {
      feedback = l10n.correctAnswer;
      feedbackColor = AppColors.green;
    } else {
      feedback = l10n.wrongAnswer;
      feedbackColor = AppColors.red;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            feedback,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: ToolFocusMetrics.chromeBodySize(context),
              fontWeight: FontWeight.w600,
              color: feedbackColor,
            ),
          ),
        ),
        if (!answered)
          Image.asset(
            'assets/images/mishka_school.png',
            height: theme.catImageSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.pets_outlined,
              size: theme.catSize * 0.7,
              color: AppColors.mainDark,
            ),
          )
        else if (selectedAnswerIndex == correctIndex)
          _buildHappyCat(theme)
        else
          _buildSadCat(theme),
      ],
    );
  }

  Widget _buildQuizScoreSummary(List<dynamic> questions) {
    final l10n = AppLocalizations.of(context)!;
    final total = questions.length;
    final correct = questionCorrect.values.where((ok) => ok).length;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    final showCongrats = percent >= 80;
    final badgeAsset = _quizBadgeAsset(percent);

    TextStyle goldTitle() => TextStyle(
          fontFamily: 'Pridi',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.mainGold,
        );

    TextStyle darkTitle() => TextStyle(
          fontFamily: 'Pridi',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.mainDark,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          badgeAsset,
          height: 190.h,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.emoji_events_outlined,
            size: 80.sp,
            color: AppColors.mainGold,
          ),
        ),
        SizedBox(height: 16.h),
        if (showCongrats) ...[
          Text(l10n.congratulation, style: goldTitle(), textAlign: TextAlign.center),
          SizedBox(height: 8.h),
        ],
        Text(
          l10n.quizYouHaveAnsweredPercent(percent),
          style: darkTitle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.correctAnswers,
          style: darkTitle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          showCongrats ? l10n.keepItUp : l10n.keepGoing,
          style: goldTitle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _quizBadgeAsset(int percent) {
    if (percent >= 100) return Assets.imagesPerfectScore;
    if (percent >= 80) return Assets.imagesScore80;
    return Assets.imagesKeepLearning;
  }

  void _finishQuiz(List<dynamic> questions) {
    final total = questions.length;
    final correct = questionCorrect.values.where((ok) => ok).length;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();

    Future<void> persistAndNavigate(int finalPercent, {String? attemptId}) async {
      _savedQuizPreviousScore = finalPercent;
      widget.onPreviousScoreChanged?.call(finalPercent);
      _persistQuizProgress(
        showResults: true,
        completed: true,
        percent: finalPercent,
      );
      _savedQuizRetaking = false;

      if (_isExpandedQuiz || _isSavedQuiz) {
        if (!mounted) return;
        final sourceId = widget.storageMessageId ??
            (widget.toolData['quizId'] ?? widget.toolData['id'] ?? '')
                .toString();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuizResultScreen(
              percent: finalPercent,
              correctCount: correct,
              totalCount: total,
              sourceId: sourceId,
              attemptId: attemptId,
            ),
          ),
        );
        return;
      }

      if (mounted) setState(() => showQuizResults = true);
    }

    if (_isSavedQuiz && widget.onSubmitSavedQuiz != null) {
      final normalized = questions
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      unawaited(() async {
        var finalPercent = percent;
        String? attemptId;
        try {
          final submitted = await widget.onSubmitSavedQuiz!(
            questions: normalized,
            selectedAnswers: Map<int, int>.from(selectedAnswers),
          );
          if (submitted != null) {
            finalPercent = submitted.percent;
            attemptId = submitted.attemptId;
          }
        } catch (_) {}
        if (!mounted) return;
        await persistAndNavigate(finalPercent, attemptId: attemptId);
      }());
      return;
    }

    unawaited(persistAndNavigate(percent));
  }

  void _finishFlashcards(int totalCards) {
    if (!mounted) return;
    final setId = (widget.toolData['flashcardSetId'] ??
            widget.toolData['flashcard_set_id'] ??
            widget.toolData['id'] ??
            widget.storageMessageId ??
            '')
        .toString();
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FlashcardsResultScreen(
            totalCards: totalCards,
            sourceId: setId,
          ),
        ),
      ),
    );
  }

  void _restoreQuestionState(int index) {
    selectedAnswerIndex = selectedAnswers[index];
    answered = selectedAnswers.containsKey(index);
  }

  // ===========================
  // MINDMAP PREVIEW
  // ===========================
  Widget _buildMindmapPreview(Map<String, dynamic> data) {
    final root = (data['root'] ?? data['title'] ?? 'Topic').toString();
    final nodes = data['nodes'] as List<dynamic>? ?? [];
    final spacious = _isExpandedMindMap || _isSavedMindMap;
    final layout = _computeMindMapLayout(root, nodes, spacious: spacious);

    Widget viewport(double height) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: _MindMapInteractiveCanvas(
              layout: layout,
              spacious: spacious,
              nodeBuilder: (spec, size) => _buildMindMapNode(
                spec,
                width: size?.width,
                height: size?.height,
                spacious: spacious,
              ),
            ),
          ),
        ),
      );
    }

    if (_isExpandedMindMap || _isSavedMindMap) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight.isFinite && constraints.maxHeight > 120
              ? constraints.maxHeight
              : 520.h;
          return viewport(height);
        },
      );
    }

    final height = _isCommunityChat
        ? ToolFocusMetrics.communityEmbeddedMindmapHeight(context)
        : ToolFocusMetrics.embeddedMindmapHeight(context);
    return viewport(height);
  }

  _MindMapLayoutSpec _computeMindMapLayout(
    String root,
    List<dynamic> nodes, {
    bool spacious = false,
  }) {
    final hGap = spacious ? 56.0 : 36.0;
    final vGap = spacious ? 96.0 : 72.0;
    final topPad = spacious ? 32.0 : 24.0;
    final childGap = spacious ? 24.0 : 18.0;
    final branchDropFactor = spacious ? 0.55 : 0.4;
    final bottomPad = spacious ? 96.0 : 72.0;
    final minBranchWidth = spacious ? 168.0 : 120.0;
    final minChildWidth = spacious ? 140.0 : 104.0;
    final columnExtraPad = spacious ? 32.0 : 12.0;

    final nodeSizesById = <String, _MindMapNodeSize>{};
    final branches = nodes
        .whereType<Map>()
        .map((node) => Map<String, dynamic>.from(node))
        .toList();

    _MindMapNodeSize measure(
      String label, {
      required bool isRoot,
      bool isChild = false,
    }) {
      final fontSize = isRoot ? 14.0 : (isChild ? 11.0 : 12.0);
      final fontWeight =
          isRoot ? FontWeight.w700 : (isChild ? FontWeight.w400 : FontWeight.w600);
      final maxTextWidth = isRoot
          ? (spacious ? 360.0 : 280.0)
          : (isChild ? (spacious ? 300.0 : 240.0) : (spacious ? 320.0 : 260.0));
      final horizontalPad = spacious ? 36.0 : 28.0;
      final verticalPad = spacious ? 28.0 : 20.0;

      final direction = studyTextDirection(label);

      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontFamily: 'Pridi',
            height: 1.25,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: direction,
        maxLines: isRoot ? 3 : 5,
      )..layout(maxWidth: maxTextWidth - horizontalPad);

      return _MindMapNodeSize(
        width: (painter.size.width + horizontalPad)
            .clamp(isChild ? minChildWidth : minBranchWidth, maxTextWidth),
        height: painter.size.height + verticalPad,
      );
    }

    final positions = <String, Offset>{};
    final edges = <(_MindMapNodeSpec, _MindMapNodeSpec)>[];
    final columnWidths = <double>[];

    for (final map in branches) {
      final title = (map['title'] ?? map['label'] ?? 'Node').toString();
      final branchSize = measure(title, isRoot: false);
      var colWidth = branchSize.width;

      final children = _mindMapChildren(map);
      for (final child in children) {
        colWidth = math.max(
          colWidth,
          measure(child, isRoot: false, isChild: true).width,
        );
      }
      columnWidths.add(colWidth + columnExtraPad);
    }

    final totalBranchSpan = columnWidths.isEmpty
        ? 200.0
        : columnWidths.fold<double>(0, (sum, w) => sum + w) +
            hGap * (columnWidths.length + 1);

    final rootSize = measure(root, isRoot: true);
    final canvasWidth = math.max(totalBranchSpan, rootSize.width + hGap * 2);
    final centerX = canvasWidth / 2;

    var maxDepthHeight = 0.0;
    for (final map in branches) {
      final title = (map['title'] ?? map['label'] ?? 'Node').toString();
      final branchSize = measure(title, isRoot: false);
      var colHeight = branchSize.height;
      for (final child in _mindMapChildren(map)) {
        colHeight +=
            measure(child, isRoot: false, isChild: true).height + childGap;
      }
      if (colHeight > maxDepthHeight) maxDepthHeight = colHeight;
    }

    final canvasHeight =
        topPad + rootSize.height + vGap + maxDepthHeight + bottomPad;

    const rootId = 'root';
    nodeSizesById[rootId] = rootSize;
    positions[rootId] = Offset(centerX - rootSize.width / 2, topPad);

    var xCursor = hGap;
    for (var i = 0; i < branches.length; i++) {
      final map = branches[i];
      final title = (map['title'] ?? map['label'] ?? 'Node').toString();
      final branchId = 'branch_$i';
      final colWidth = columnWidths[i];
      final branchSize = measure(title, isRoot: false);
      nodeSizesById[branchId] = branchSize;

      final x = xCursor + (colWidth - branchSize.width) / 2;
      final y = topPad + rootSize.height + vGap * branchDropFactor;
      final colLeft = xCursor;
      positions[branchId] = Offset(x, y);
      edges.add((_MindMapNodeSpec(id: rootId), _MindMapNodeSpec(id: branchId)));
      xCursor += colWidth + hGap;

      final children = _mindMapChildren(map);
      var childY = y + branchSize.height + (spacious ? 24.0 : 18.0);
      for (var j = 0; j < children.length; j++) {
        final childId = 'child_${i}_$j';
        final childLabel = children[j];
        final childSize = measure(childLabel, isRoot: false, isChild: true);
        nodeSizesById[childId] = childSize;
        positions[childId] = Offset(
          colLeft + (colWidth - childSize.width) / 2,
          childY,
        );
        childY += childSize.height + childGap;
        edges.add((
          _MindMapNodeSpec(id: branchId),
          _MindMapNodeSpec(id: childId),
        ));
      }
    }

    final nodeWidgets = <_MindMapNodeSpec, Offset>{};
    nodeWidgets[_MindMapNodeSpec(id: rootId, label: root, isRoot: true)] =
        positions[rootId]!;
    for (var i = 0; i < branches.length; i++) {
      final map = branches[i];
      final title = (map['title'] ?? map['label'] ?? 'Node').toString();
      final branchId = 'branch_$i';
      nodeWidgets[_MindMapNodeSpec(id: branchId, label: title)] =
          positions[branchId]!;
      final children = _mindMapChildren(map);
      for (var j = 0; j < children.length; j++) {
        final childId = 'child_${i}_$j';
        nodeWidgets[_MindMapNodeSpec(
          id: childId,
          label: children[j],
          isChild: true,
        )] = positions[childId]!;
      }
    }

    return _MindMapLayoutSpec(
      width: canvasWidth,
      height: canvasHeight,
      centerX: centerX,
      nodePositions: nodeWidgets,
      edges: edges,
      positionsById: positions,
      nodeSizesById: nodeSizesById,
    );
  }

  List<String> _mindMapChildren(Map<String, dynamic> node) {
    final raw = node['children'] ?? node['subtopics'] ?? node['branches'];
    if (raw is! List) return const [];
    return raw.map((child) {
      if (child is Map) {
        final row = Map<String, dynamic>.from(child);
        return (row['title'] ?? row['label'] ?? row['name'] ?? row['text'] ?? 'Child')
            .toString();
      }
      return child.toString();
    }).toList();
  }

  Widget _buildMindMapNode(
    _MindMapNodeSpec spec, {
    double? width,
    double? height,
    bool spacious = false,
  }) {
    final nodeWidth = width ?? (spacious ? 220.0 : 180.0);
    final hPad = spacious ? 18.0 : 14.0;
    final vPad = spacious ? 14.0 : 10.0;

    return SizedBox(
      width: nodeWidth,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: spec.isRoot
              ? AppColors.mainDark
              : (spec.isChild ? Colors.white : AppColors.screenBackground),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.mainDark,
            width: spec.isRoot ? 2.5 : (spec.isChild ? 1 : 1.5),
          ),
          boxShadow: spec.isRoot
              ? [
                  BoxShadow(
                    color: AppColors.mainDark.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: StudyText(
          spec.label,
          style: TextStyle(
            fontSize: spec.isRoot ? 14 : (spec.isChild ? 11 : 12),
            fontWeight: spec.isRoot
                ? FontWeight.w700
                : (spec.isChild ? FontWeight.w400 : FontWeight.w600),
            color: spec.isRoot ? Colors.white : AppColors.mainDark,
            fontFamily: 'Pridi',
            height: 1.25,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  // ===========================
  // CAT IMAGES
  // ===========================
  Widget _buildHappyCat(_QuizTheme theme) {
    return Container(
      height: theme.catSize,
      width: theme.catSize,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/mishka_happy.png',
        height: theme.catImageSize,
        width: theme.catImageSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sentiment_very_satisfied,
            size: theme.catSize * 0.6,
            color: const Color(0xFF4CAF50),
          );
        },
      ),
    );
  }

  Widget _buildSadCat(_QuizTheme theme) {
    return Container(
      height: theme.catSize,
      width: theme.catSize,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/mishka_sad.png',
        height: theme.catImageSize,
        width: theme.catImageSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.sentiment_very_dissatisfied,
            size: theme.catSize * 0.6,
            color: const Color(0xFFF44336),
          );
        },
      ),
    );
  }

  // ===========================
  // HELPERS
  // ===========================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Text(
          "No content to display",
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.greyText,
            fontFamily: 'Pridi',
          ),
        ),
      ),
    );
  }

  void _nextQuestion() {
    final questions =
        normalizeToolData(widget.toolData)['questions'] as List<dynamic>? ?? [];
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _restoreQuestionState(currentQuestionIndex);
      });
      _persistQuizProgress();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _restoreQuestionState(currentQuestionIndex);
      });
      _persistQuizProgress();
    }
  }

}

class _MindMapNodeSize {
  const _MindMapNodeSize({required this.width, required this.height});

  final double width;
  final double height;
}

class _MindMapInteractiveCanvas extends StatefulWidget {
  const _MindMapInteractiveCanvas({
    required this.layout,
    required this.spacious,
    required this.nodeBuilder,
  });

  final _MindMapLayoutSpec layout;
  final bool spacious;
  final Widget Function(_MindMapNodeSpec spec, _MindMapNodeSize? size) nodeBuilder;

  @override
  State<_MindMapInteractiveCanvas> createState() =>
      _MindMapInteractiveCanvasState();
}

class _MindMapInteractiveCanvasState extends State<_MindMapInteractiveCanvas> {
  final TransformationController _controller = TransformationController();
  bool _initialFitApplied = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyInitialFitIfNeeded(Size viewportSize) {
    if (_initialFitApplied || !widget.spacious) return;
    if (viewportSize.width <= 0 || viewportSize.height <= 0) return;

    final content = Size(widget.layout.width, widget.layout.height);
    final margin = 24.0;
    final scaleX = (viewportSize.width - margin * 2) / content.width;
    final scaleY = (viewportSize.height - margin * 2) / content.height;
    final scale = math.min(scaleX, scaleY).clamp(0.25, 1.0);

    final dx = (viewportSize.width - content.width * scale) / 2;
    final dy = (viewportSize.height - content.height * scale) / 2;

    _controller.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    _initialFitApplied = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _applyInitialFitIfNeeded(viewportSize);
        });

        return InteractiveViewer(
          transformationController: _controller,
          boundaryMargin: EdgeInsets.all(widget.spacious ? 120 : 80),
          minScale: 0.25,
          maxScale: 3.0,
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          alignment: Alignment.center,
          child: SizedBox(
            width: widget.layout.width,
            height: widget.layout.height,
            child: CustomPaint(
              painter: _MindMapPainter(layout: widget.layout),
              child: Stack(
                clipBehavior: Clip.none,
                children: widget.layout.nodePositions.entries.map((entry) {
                  final pos = entry.value;
                  final spec = entry.key;
                  final size = widget.layout.nodeSizesById[spec.id];
                  return Positioned(
                    left: pos.dx,
                    top: pos.dy,
                    child: widget.nodeBuilder(spec, size),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MindMapNodeSpec {
  const _MindMapNodeSpec({
    required this.id,
    this.label = '',
    this.isRoot = false,
    this.isChild = false,
  });

  final String id;
  final String label;
  final bool isRoot;
  final bool isChild;

  @override
  bool operator ==(Object other) =>
      other is _MindMapNodeSpec && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _MindMapLayoutSpec {
  const _MindMapLayoutSpec({
    required this.width,
    required this.height,
    required this.centerX,
    required this.nodePositions,
    required this.edges,
    required this.positionsById,
    required this.nodeSizesById,
  });

  final double width;
  final double height;
  final double centerX;
  final Map<_MindMapNodeSpec, Offset> nodePositions;
  final List<(_MindMapNodeSpec, _MindMapNodeSpec)> edges;
  final Map<String, Offset> positionsById;
  final Map<String, _MindMapNodeSize> nodeSizesById;
}

// ===========================
// MIND MAP PAINTER
// ===========================
class _MindMapPainter extends CustomPainter {
  _MindMapPainter({required this.layout});

  final _MindMapLayoutSpec layout;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mainDark.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Offset centerOf(String id) {
      final pos = layout.positionsById[id];
      final size = layout.nodeSizesById[id];
      if (pos == null || size == null) return Offset.zero;
      return Offset(pos.dx + size.width / 2, pos.dy + size.height / 2);
    }

    for (final edge in layout.edges) {
      final from = centerOf(edge.$1.id);
      final to = centerOf(edge.$2.id);
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapPainter oldDelegate) =>
      oldDelegate.layout != layout;
}

class _FlashcardIconBadge extends StatelessWidget {
  const _FlashcardIconBadge({
    required this.containerSize,
    required this.iconSize,
    this.imagePath,
  });

  final String? imagePath;
  final double containerSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: AppColors.lightFrameBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: imagePath != null
          ? Image.asset(
              imagePath!,
              fit: BoxFit.contain,
              width: containerSize * 0.82,
              height: containerSize * 0.82,
              errorBuilder: (_, __, ___) => Icon(
                Icons.menu_book_outlined,
                size: iconSize,
                color: AppColors.mainGold,
              ),
            )
          : Icon(
              Icons.menu_book_outlined,
              size: iconSize,
              color: AppColors.mainGold,
            ),
    );
  }
}

class _FlashcardNavButton extends StatelessWidget {
  const _FlashcardNavButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? (enabled ? AppColors.blue : AppColors.blue.withValues(alpha: 0.45))
        : (enabled ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0));
    final fg = filled ? Colors.white : AppColors.mainDark;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: ToolFocusMetrics.navButtonPadding(context),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: ToolFocusMetrics.navButtonFontSize(context),
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedQuizNavButton extends StatelessWidget {
  const _SavedQuizNavButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback? onTap;
  final _QuizTheme theme;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? (enabled ? AppColors.blue : AppColors.blue.withValues(alpha: 0.45))
        : (enabled ? const Color(0xFFBDBDBD) : const Color(0xFFE0E0E0));
    final fg = filled ? Colors.white : AppColors.mainDark;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(theme.navRadius),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(theme.navRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.navHorizontalPadding,
            vertical: theme.navVerticalPadding,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: theme.navTextSize,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizNavButton extends StatelessWidget {
  const _QuizNavButton({
    required this.label,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final VoidCallback onTap;
  final _QuizTheme theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blue,
      borderRadius: BorderRadius.circular(theme.navRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.navRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.navHorizontalPadding,
            vertical: theme.navVerticalPadding,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: theme.navTextSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizTheme {
  const _QuizTheme({
    required this.questionSize,
    required this.progressSize,
    required this.optionTextSize,
    required this.resultLabelSize,
    required this.navTextSize,
    required this.optionHorizontalPadding,
    required this.optionVerticalPadding,
    required this.optionSpacing,
    required this.optionRadius,
    required this.radioSize,
    required this.radioDotSize,
    required this.radioTopInset,
    required this.gapSmall,
    required this.gapMedium,
    required this.gapLarge,
    required this.navHorizontalPadding,
    required this.navVerticalPadding,
    required this.navRadius,
    required this.catSize,
    required this.catImageSize,
  });

  final double questionSize;
  final double progressSize;
  final double optionTextSize;
  final double resultLabelSize;
  final double navTextSize;
  final double optionHorizontalPadding;
  final double optionVerticalPadding;
  final double optionSpacing;
  final double optionRadius;
  final double radioSize;
  final double radioDotSize;
  final double radioTopInset;
  final double gapSmall;
  final double gapMedium;
  final double gapLarge;
  final double navHorizontalPadding;
  final double navVerticalPadding;
  final double navRadius;
  final double catSize;
  final double catImageSize;

  static final saved = _QuizTheme(
    questionSize: 14.sp,
    progressSize: 12.sp,
    optionTextSize: 13.sp,
    resultLabelSize: 11.sp,
    navTextSize: 12.sp,
    optionHorizontalPadding: 10.w,
    optionVerticalPadding: 9.h,
    optionSpacing: 7.h,
    optionRadius: 8.r,
    radioSize: 18.w,
    radioDotSize: 8.w,
    radioTopInset: 2.h,
    gapSmall: 3.h,
    gapMedium: 6.w,
    gapLarge: 10.h,
    navHorizontalPadding: 16.w,
    navVerticalPadding: 7.h,
    navRadius: 8.r,
    catSize: 52.h,
    catImageSize: 46.h,
  );

  static final embedded = _QuizTheme(
    questionSize: 13.sp,
    progressSize: 12.sp,
    optionTextSize: 12.sp,
    resultLabelSize: 11.sp,
    navTextSize: 12.sp,
    optionHorizontalPadding: 10.w,
    optionVerticalPadding: 10.h,
    optionSpacing: 8.h,
    optionRadius: 8.r,
    radioSize: 18.w,
    radioDotSize: 8.w,
    radioTopInset: 2.h,
    gapSmall: 4.h,
    gapMedium: 8.w,
    gapLarge: 12.h,
    navHorizontalPadding: 16.w,
    navVerticalPadding: 8.h,
    navRadius: 8.r,
    catSize: 100.h,
    catImageSize: 90.h,
  );

  static final expanded = _QuizTheme(
    questionSize: 17.sp,
    progressSize: 15.sp,
    optionTextSize: 15.sp,
    resultLabelSize: 13.sp,
    navTextSize: 15.sp,
    optionHorizontalPadding: 14.w,
    optionVerticalPadding: 14.h,
    optionSpacing: 12.h,
    optionRadius: 10.r,
    radioSize: 22.w,
    radioDotSize: 10.w,
    radioTopInset: 3.h,
    gapSmall: 6.h,
    gapMedium: 10.w,
    gapLarge: 16.h,
    navHorizontalPadding: 22.w,
    navVerticalPadding: 12.h,
    navRadius: 10.r,
    catSize: 120.h,
    catImageSize: 108.h,
  );
}

