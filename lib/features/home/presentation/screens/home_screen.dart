import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/main.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/tip_of_the_day_card.dart';
import '../widgets/ai_tool_card.dart';
import '../widgets/community_card.dart';
import '../widgets/support_badge_card.dart';

class HomeScreen extends StatelessWidget {
  final void Function(MainTab)? onTabSwitch;
  final void Function(CategoryScreenType)? onCategoryNavigate;

  const HomeScreen({
    super.key,
    this.onTabSwitch,
    this.onCategoryNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "Mishka",
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
            _buildWelcomeSection(context, l10n),
            SizedBox(height: 32.h),
            
            // Daily Streaks Section
            _buildStreaksSection(context, l10n),
            SizedBox(height: 24.h),
            
            // Tip of the Day
            TipOfTheDayCard(l10n: l10n),
            SizedBox(height: 24.h),
            
            // Upcoming Deadlines
            _buildUpcomingDeadlines(context, l10n),
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
            SizedBox(height: 80.h), // Space before end of screen
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding:  EdgeInsets.only(left:AppSizes.paddingMedium,right: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBackSara,
                  style: TextStyle(
                    fontFamily: "Pridi",
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.sundayJan26,
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

  Widget _buildStreaksSection(BuildContext context, AppLocalizations l10n) {
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

                Row(
                  children: [
                    Iconify(
                      Mdi.fire,
                      size: 18.w,
                      color: AppColors.mainGold,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10n.days(3),
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayItem(context, l10n.mon, true, false), // Completed
                _buildDayItem(context, l10n.tue, true, false), // Completed
                _buildDayItem(context, l10n.wed, true, false), // Completed
                _buildDayItem(context, l10n.thu, false, true), // Today
                _buildDayItem(context, l10n.fri, false, false), // Upcoming
                _buildDayItem(context, l10n.sat, false, false), // Upcoming
                _buildDayItem(context, l10n.sun, false, false), // Upcoming
              ],
            ),
            SizedBox(height: 16.h),

            Divider(color: AppColors.stroke, height: 1.h),
            SizedBox(height: 16.h),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.mainGold, l10n.completed),
                SizedBox(width: 16.w),
                _buildLegendItem(AppColors.white, l10n.today),
                SizedBox(width: 16.w),
                _buildLegendItem(AppColors.lightFrameBackground, l10n.upcoming),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, String day, bool completed, bool isToday) {
    Color bgColor;
    Widget? icon;
    
    if (completed) {
      bgColor = AppColors.mainGold;
      icon = Iconify(
        Mdi.check,
        size: 20.w,
        color: AppColors.white,
      );
    } else if (isToday) {
      bgColor = AppColors.white;
      icon = Image.asset(
        Assets.imagesStreakToday,
        width: 22.w,
        height: 30.w,
        fit: BoxFit.contain,
      );
    } else {
      bgColor = AppColors.lightFrameBackground;
      icon = null;
    }
    
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
            border: isToday ? Border.all(color: AppColors.mainGold, width: 2) : null,
          ),
          child: Center(
            child: icon ?? Text(
              day,
              style: TextStyle(
                fontFamily: "Pridi",
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == AppColors.white ? Border.all(color: AppColors.stroke) : null,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontFamily: "Pridi",
            fontSize: 10.sp,
            color: AppColors.lightText,
          ),

        ),
      ],
    );
  }

  Widget _buildUpcomingDeadlines(BuildContext context, AppLocalizations l10n) {
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
                  onTabSwitch?.call(MainTab.todo);
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
          Row(
            children: [
              Expanded(
                child: _buildTaskCard(
                  context,
                  l10n,
                  l10n.plcSheet2Offline,
                  l10n.collegeTasksList,
                  l10n.sunJan262025,
                  "07:00 pm",
                  true, // completed
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTaskCard(
                  context,
                  l10n,
                  l10n.meetingForGraduationProject,
                  l10n.workTasksList,
                  l10n.sunJan262025,
                  "09:00 pm",
                  false, // not completed
                ),
              ),
            ],
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
    final deadlineColor = isCompleted ? AppColors.green : AppColors.red;
    final bgColor = isCompleted ? AppColors.screenBackground : AppColors.white;
    
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mainGold : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: isCompleted ? AppColors.mainGold : AppColors.stroke,
              ),
            ),
            child: isCompleted
                ? Iconify(
                    Mdi.check,
                    size: 16.w,
                    color: AppColors.white,
                  )
                : null,
          ),
          SizedBox(height: 8.h),
          Text(
            "${l10n.task} $task",
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: AppSizes.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${l10n.list} $list",
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "${l10n.deadline} $deadline",
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: deadlineColor,
            ),
          ),
          SizedBox(height: 4.h),
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
    );
  }

  Widget _buildAiToolsSection(BuildContext context, AppLocalizations l10n) {
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
                  onCategoryNavigate?.call(CategoryScreenType.aiTools);
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
          AiToolCard(
          title: 'Chat with Mishka',
          imagePath:Assets.imagesHomeChatCard,
          onTap: () {
            // Navigate to Chat with Mishka screen
            onCategoryNavigate?.call(CategoryScreenType.chatWithMishka);
          },
          cornerPosition: CardCornerPosition.topLeft,
          ),
          AiToolCard(
          title: 'Summarize with Mishka',
          imagePath: Assets.imagesHomeSumaryQuizzesCard,
      onTap: () {
        // Navigate to Chat with Mishka where summaries can be created
        onCategoryNavigate?.call(CategoryScreenType.chatWithMishka);
      },
      cornerPosition: CardCornerPosition.topRight,
      ),
      AiToolCard(
      title: 'Flash Cards',
      imagePath: Assets.imagesHomeFlashcardsCard,
      onTap: () {
        // Navigate to Chat with Mishka where flashcards can be created
        onCategoryNavigate?.call(CategoryScreenType.chatWithMishka);
      },
      cornerPosition: CardCornerPosition.bottomLeft,
      ),
      AiToolCard(
      title: 'Quizzes',
      imagePath:Assets.imagesHomeSumaryQuizzesCard,
      onTap: () {
        // Navigate to Chat with Mishka where quizzes can be created
        onCategoryNavigate?.call(CategoryScreenType.chatWithMishka);
      },
      cornerPosition: CardCornerPosition.bottomRight,
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
                  onCategoryNavigate?.call(CategoryScreenType.studyWithMe);
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
                  onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
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
                    onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
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
                    // Navigate to Our Community screen
                    onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
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
              // Navigate to Our Community screen
              onCategoryNavigate?.call(CategoryScreenType.ourCommunity);
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
                  onCategoryNavigate?.call(CategoryScreenType.gamefaction);
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
