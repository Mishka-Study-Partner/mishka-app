import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/direct_tool_generator_screen.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/ctegory/data/repositories/category_repository.dart';
import 'package:mishka_app/features/ctegory/utils/ai_tool_ui_helper.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/daily_streak_ping.dart';
import 'package:mishka_app/features/home/data/repositories/home_repository.dart';
import 'package:mishka_app/features/todo_lists/data/task_due_fields.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/features/todo_lists/data/repositories/todo_repository.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/main.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import '../widgets/daily_streak_week_row.dart';
import '../widgets/tip_of_the_day_card.dart';
import '../widgets/ai_tool_card.dart';
import '../widgets/community_card.dart';
import '../widgets/support_badge_card.dart';
import 'package:mishka_app/features/our_community/presentation/screens/community_discover_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(MainTab)? onTabSwitch;
  final void Function(
    CategoryScreenType screen, {
    bool focusSavedCommunities,
  })? onCategoryNavigate;

  const HomeScreen({
    super.key,
    this.onTabSwitch,
    this.onCategoryNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _homeRepository = HomeRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TodoRepository _todoRepository = TodoRepository();
  int _streakDays = 0;
  int _freezesRemaining = 0;
  List<DailyStreakDayModel> _streakWeek = const [];
  bool _streakLoaded = false;
  String? _tipText;
  List<TaskApiModel> _upcomingTasks = const [];
  List<AiToolApiModel> _aiTools = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AiToolUiHelper.evictHomeCardImages();
    _restoreCachedStreak();
    _initHome();
  }

  void _restoreCachedStreak() {
    final raw = AppPreferences.cachedDailyStreakJson;
    if (raw == null || raw.isEmpty) return;
    try {
      final model = DailyStreakModel.fromJson(jsonDecode(raw));
      _streakDays = model.currentStreak;
      _freezesRemaining = model.freezesRemaining;
      _streakWeek = model.week;
      _streakLoaded = true;
    } catch (_) {}
  }

  Future<void> _applyStreakModel(DailyStreakModel model) async {
    if (!mounted) return;
    setState(() {
      _streakDays = model.currentStreak;
      _freezesRemaining = model.freezesRemaining;
      _streakWeek = model.week;
      _streakLoaded = true;
    });
    await AppPreferences.setCachedDailyStreakJson(
      jsonEncode(model.toJson()),
    );
  }

  Future<void> _initHome() async {
    await DailyStreakPing.whenPingSettled();
    final pingResult = await DailyStreakPing().recordAppOpenIfNeeded();
    if (pingResult != null) {
      await _applyStreakModel(pingResult);
    }
    await _loadHomeData();
  }

  Future<void> _loadStreak() async {
    try {
      final streakModel = await _homeRepository.getDailyStreak();
      await _applyStreakModel(streakModel);
    } catch (_) {
      // Keep cached streak when the streak endpoint fails.
    }
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    await _loadStreak();
    try {
      final results = await Future.wait([
        _homeRepository.getTips(),
        _homeRepository.getUpcomingTasks(),
        _categoryRepository.getAiTools(),
      ]);
      if (!mounted) return;
      final tasks = (results[1] as List<TaskApiModel>).toList()
        ..sort((a, b) {
          final ad = a.deadline ?? DateTime(9999);
          final bd = b.deadline ?? DateTime(9999);
          return ad.compareTo(bd);
        });
      final apiTools = results[2] as List<AiToolApiModel>;
      setState(() {
        _tipText = (results[0] as dynamic).isNotEmpty
            ? (results[0] as dynamic).first.text as String
            : null;
        _upcomingTasks = tasks.take(2).toList();
        _aiTools = apiTools;
      });
    } catch (_) {
      // Keep UI usable with defaults when backend data fails.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _apiErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }

  Future<void> _toggleTask(TaskApiModel task) async {
    final l10n = AppLocalizations.of(context)!;
    final wasCompleted = task.completed ?? false;
    final newStatus = wasCompleted ? 'pending' : 'completed';

    try {
      await _todoRepository.patchTask(id: task.id, status: newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasCompleted ? l10n.taskMarkedPending : l10n.taskMarkedComplete,
          ),
        ),
      );
      await _loadHomeData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${_apiErrorMessage(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthBloc>().state;
    final firstName = authState is AuthSuccess ? authState.user.firstName : null;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.appTitle,
        showBack: false,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
      //  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            
            // Welcome Section
            _buildWelcomeSection(context, l10n, firstName),
            SizedBox(height: 32.h),
            
            // Daily Streaks Section
            _buildStreaksSection(context, l10n, _streakDays),
            SizedBox(height: 24.h),
            
            // Tip of the Day
            TipOfTheDayCard(l10n: l10n, tipText: _tipText),
            SizedBox(height: 24.h),
            
            // Upcoming Deadlines
            _buildUpcomingDeadlines(context, l10n, _upcomingTasks),
            SizedBox(height: 24.h),
            
            // Mishka's AI Tools
            _buildAiToolsSection(context, l10n),
            SizedBox(height: 24.h),
            
            // Study With Mishka
            _buildStudyWithMishka(context, l10n),
            SizedBox(height: 24.h),
            
            // Mishka's Community
            _buildCommunitySection(context, l10n),
            SizedBox(height: 24.h),
            
            // Mishka's Support
            _buildSupportSection(context, l10n),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            const ScreenEndSpacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    AppLocalizations l10n,
    String? firstName,
  ) {
    final localeName = Localizations.localeOf(context).toString();
    final today = DateTime.now();
    final formattedDate = DateFormat.yMMMMEEEEd(localeName).format(today);

    return Padding(
      padding: EdgeInsets.only(left: AppSizes.paddingMedium, right: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName == null || firstName.isEmpty
                      ? l10n.welcomeBackToMishka
                      : l10n.welcomeBackName(firstName),
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Image.asset(
            Assets.imagesHomeTopCards,
            width: 139.w,
            height: 55.h,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Future<void> _freezeMissedDay(DailyStreakDayModel day) async {
    if (!day.isMissed || day.date.isEmpty || _freezesRemaining <= 0) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.streakFreezeTitle),
        content: Text(l10n.streakFreezeMessage(day.date)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.streakFreezeConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final updated = await _homeRepository.freezeStreakDay(date: day.date);
      if (!mounted) return;
      await _applyStreakModel(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.streakFreezeSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.streakFreezeFailed)),
      );
    }
  }

  Widget _buildStreaksSection(
    BuildContext context,
    AppLocalizations l10n,
    int streakDays,
  ) {
    final compact = AppBreakpoints.isTablet(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: compact ? 8.h : AppSizes.paddingMedium,
      ),
      child: Container(
        padding: EdgeInsets.all(compact ? 12.w : AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.greyText),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dailyStreaks,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: compact
                        ? AppSizes.fontSizeMedium
                        : AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                Row(
                  children: [
                    Iconify(
                      Mdi.fire,
                      size: compact ? 16.w : 18.w,
                      color: AppColors.mainGold,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _streakLoaded ? l10n.days(streakDays) : '—',
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: compact
                            ? AppSizes.fontSizeMedium
                            : AppSizes.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: compact ? 10.h : 16.h),
            DailyStreakWeekRow(
              week: _streakWeek,
              freezesRemaining: _freezesRemaining,
              onFreezeTap: _freezeMissedDay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeadlines(
    BuildContext context,
    AppLocalizations l10n,
    List<TaskApiModel> tasks,
  ) {
    return Padding(
      padding:  EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.upComingDeadlines,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onTabSwitch?.call(MainTab.todo);
                },
                child: Text(
                  "${l10n.viewYourToDoList} >",
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (tasks.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Text(
                l10n.noUpcomingDeadlinesYet,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.lightText,
                ),
              ),
            )
          else
            SizedBox(
              height: 220.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final localeName = Localizations.localeOf(context).toString();
                  final dateText = TaskDueFields.formatDate(task.deadline, localeName);
                  final timeText = TaskDueFields.formatTime(
                    deadline: task.deadline,
                    hasDueTime: task.hasDueTime,
                    locale: localeName,
                    empty: '--:--',
                  );
                  final screenW = MediaQuery.sizeOf(context).width;
                  final cardWidth = AppBreakpoints.isTablet(context)
                      ? screenW * 0.38
                      : screenW * 0.55;
                  return SizedBox(
                    width: cardWidth,
                    child: _buildTaskCard(
                      context,
                      l10n,
                      task,
                      dateText,
                      timeText,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    AppLocalizations l10n,
    TaskApiModel task,
    String deadlineText,
    String timeText,
  ) {
    final isCompleted = task.completed ?? false;
    final deadlineColor = isCompleted ? const Color(0xFF4A7C59) : AppColors.blue;
    final bgColor = isCompleted ? const Color(0xFFFFFDF5) : AppColors.white;
    final checkboxBorder = isCompleted ? AppColors.mainGold : AppColors.greyText;
    final checkboxFill = isCompleted
        ? AppColors.mainGold.withValues(alpha: 0.15)
        : Colors.transparent;

    final sideBarColor = isCompleted ? AppColors.mainGold : AppColors.greyText;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left color stripe (inside the card with padding)
          Container(
            width: 3.w,
            decoration: BoxDecoration(
              color: sideBarColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          // Card content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  InkWell(
                    onTap: () => _toggleTask(task),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: checkboxFill,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: checkboxBorder),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 16.w,
                              color: AppColors.mainGold,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Task label
                  Text(
                    l10n.task,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainDark,
                    ),
                  ),
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // List label
                  Text(
                    l10n.list,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainDark,
                    ),
                  ),
                  Text(
                    task.todoListTitle ?? l10n.yourList,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Deadline label
                  Text(
                    l10n.deadline,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainDark,
                    ),
                  ),
                  Text(
                    deadlineText,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: deadlineColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: deadlineColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAiTool(BuildContext context, AiToolApiModel tool) {
    final kind = AiToolUiHelper.directKindForTitle(tool.title);
    if (kind != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DirectToolGeneratorScreen(
            kind: kind,
            title: tool.title,
          ),
        ),
      );
      return;
    }
    widget.onCategoryNavigate?.call(CategoryScreenType.chatWithMishka);
  }

  Widget _buildAiToolsSection(BuildContext context, AppLocalizations l10n) {
    final tools = _aiTools.isNotEmpty
        ? _aiTools.take(4).toList()
        : AiToolUiHelper.fallbackTools(
            chatTitle: l10n.chatWithMishka,
            summarizeTitle: l10n.summarizeWithMishka,
            flashcardsTitle: l10n.flashCards,
            quizzesTitle: l10n.quizzes,
          );

    return Padding(
      padding:  EdgeInsets.only(left: AppSizes.paddingMedium,right: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mishkasAiTools,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onCategoryNavigate?.call(CategoryScreenType.aiTools);
                },
                child: Text(
                  "${l10n.viewMore} >",
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: AppBreakpoints.isTablet(context) ? 1.75 : 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < tools.length; i++)
                AiToolCard(
                  title: tools[i].title,
                  imagePath: AiToolUiHelper.imageForTitle(tools[i].title),
                  onTap: () => _openAiTool(context, tools[i]),
                  cornerPosition: AiToolUiHelper.cornerForIndex(i),
                ),
            ],
          ),

      ],
      ),
    );
  }

  Widget _buildStudyWithMishka(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(left: AppSizes.paddingMedium,right: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.studyWithMishka,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onCategoryNavigate?.call(CategoryScreenType.studyWithMe);
                },
                child: Text(
                  "${l10n.start} >",
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            height: 180.h,
            decoration: BoxDecoration(
              color: AppColors.mainDark,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Image.asset(
                Assets.imagesStudyWithMishkaHome,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(left: AppSizes.paddingMedium,right: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mishkasCommunity,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
                },
                child: Text(
                  "${l10n.join} >",
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Two cards in a row
          Row(
            children: [
              Expanded(
                child: CommunityCard(
                  icon: Mdi.people,
                  text: l10n.youCanAddNewCommunity,
                  l10n: l10n,
                  isRowLayout: false,
                  onStart: () {
                    // Navigate to Our Community screen
                    widget.onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CommunityCard(
                  icon: Mdi.log_in,
                  text: l10n.youCanRejoinSavedCommunity,
                  l10n: l10n,
                  isRowLayout: false,
                  onStart: () {
                    widget.onCategoryNavigate?.call(
                      CategoryScreenType.ourCommunity,
                      focusSavedCommunities: true,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Full width card below
          CommunityCard(
            icon: Mdi.compass_outline,
            text: l10n.exploreCommunitiesByMajor,
            l10n: l10n,
            isRowLayout: true,
            onStart: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CommunityDiscoverScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(left: AppSizes.paddingMedium,right: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.mishkasSupport,
                style: TextStyle(
                  fontFamily: "Pridi",
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onCategoryNavigate?.call(CategoryScreenType.gamification);
                },
                child: Text(
                  "${l10n.exploreMore} >",
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: SupportBadgeCard(
                  imagePath: Assets.imagesMiskaSupport1,
                  title1: l10n.supportStudyHoursBadge,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SupportBadgeCard(
                  imagePath: Assets.imagesMishkaSupport2,
                  title1: l10n.supportChallengesBadge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
