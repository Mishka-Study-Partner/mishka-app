import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/direct_tool_generator_screen.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/ctegory/data/repositories/category_repository.dart';
import 'package:mishka_app/features/ctegory/utils/ai_tool_ui_helper.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/repositories/home_repository.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/main.dart';

import '../../../../l10n/app_localizations.dart';
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
  int _streakDays = 0;
  int _freezesRemaining = 0;
  List<DailyStreakDayModel> _streakWeek = const [];
  String? _tipText;
  List<TaskApiModel> _upcomingTasks = const [];
  List<AiToolApiModel> _aiTools = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _homeRepository.getDailyStreak(),
        _homeRepository.getTips(),
        _homeRepository.getUpcomingTasks(),
        _categoryRepository.getAiTools(),
      ]);
      if (!mounted) return;
      final tasks = (results[2] as List<TaskApiModel>).toList()
        ..sort((a, b) {
          final ad = a.deadline ?? DateTime(9999);
          final bd = b.deadline ?? DateTime(9999);
          return ad.compareTo(bd);
        });
      final streakModel = results[0] as DailyStreakModel;
      final apiTools = results[3] as List<AiToolApiModel>;
      setState(() {
        _streakDays = streakModel.currentStreak;
        _freezesRemaining = streakModel.freezesRemaining;
        _streakWeek = streakModel.week;
        _tipText = (results[1] as dynamic).isNotEmpty
            ? (results[1] as dynamic).first.text as String
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
            SizedBox(height: 80.h), // Space before end of screen
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
                      ? l10n.welcomeBackSara
                      : 'Welcome back, $firstName',
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
      setState(() {
        _streakDays = updated.currentStreak;
        _freezesRemaining = updated.freezesRemaining;
        _streakWeek = updated.week;
      });
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
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
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
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Iconify(
                          Mdi.fire,
                          size: 18.w,
                          color: AppColors.mainGold,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          l10n.days(streakDays),
                          style: TextStyle(
                            fontFamily: "Pridi",
                            fontSize: AppSizes.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
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
                  final deadline = task.deadline;
                  final dateText = deadline == null
                      ? '-'
                      : DateFormat('EEE, MMM d, yyyy').format(deadline);
                  final timeText = deadline == null
                      ? '--:--'
                      : DateFormat('hh:mm a').format(deadline);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: _buildTaskCard(
                      context,
                      l10n,
                      task.title,
                      task.todoListTitle ?? l10n.yourList,
                      dateText,
                      timeText,
                      task.completed ?? false,
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
    String task,
    String list,
    String deadline,
    String time,
    bool isCompleted,
  ) {
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
                  Container(
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
                    task,
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
                    list,
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
                    deadline,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: deadlineColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    time,
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
      childAspectRatio: 1.6,

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
      )

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
                  widget.onCategoryNavigate?.call(CategoryScreenType.gamefaction);
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
                  title1: "Count Your daily study hours with Mishka",

                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SupportBadgeCard(
                  imagePath: Assets.imagesMishkaSupport2,
                  title1: "Win Mishka’s Challenges and get your PrizeL",

                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
