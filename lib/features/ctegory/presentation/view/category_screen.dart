import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../main.dart';
import '../widgets/category_section_card.dart';

class CategoryScreen extends StatelessWidget {
  final void Function(CategoryScreenType) onNavigate;
  final void Function(MainTab)? onTabSwitch;
  
  CategoryScreen({
    super.key,
    required this.onNavigate,
    this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "",
        showBack: true,
        showBottomBar: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SectionCard(
                imagePath: Assets.imagesAiTools,
                title: l10n.aiTools,
                subtitle: l10n.aiToolsSubtitle,
                onTap: () => onNavigate(CategoryScreenType.aiTools),
              ),
              SizedBox(height: 12.h),
              SectionCard(
                imagePath: Assets.imagesStudyWithMe,
                title: l10n.studyWithMe,
                subtitle: l10n.studyWithMeSubtitle,
                onTap: () => onNavigate(CategoryScreenType.studyWithMe),
              ),
              SizedBox(height: 12.h),
              SectionCard(
                imagePath: Assets.imagesOurCommunity,
                title: l10n.ourCommunity,
                subtitle: l10n.ourCommunitySubtitle,
                onTap: () => onNavigate(CategoryScreenType.ourCommunity),
              ),
              SizedBox(height: 12.h),
              SectionCard(
                imagePath: Assets.imagesToDoList,
                title: l10n.toDoList,
                subtitle: l10n.yourToDoList,
                // Navigate to Todo tab
                onTap: () {
                  onTabSwitch?.call(MainTab.todo);
                },
              ),
              SizedBox(height: 12.h),
              SectionCard(
                imagePath: Assets.imagesGamification,
                title: l10n.gamification,
                subtitle: l10n.gamificationSubtitle,
                onTap: () => onNavigate(CategoryScreenType.gamefaction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}