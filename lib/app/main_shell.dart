import 'package:flutter/material.dart';

import 'package:mishka_app/core/widgets/custom_nav_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/chat_with_mishka_screen.dart';
import 'package:mishka_app/features/ctegory/presentation/view/ai_tools_screen.dart';
import 'package:mishka_app/features/ctegory/presentation/view/category_screen.dart';
import 'package:mishka_app/features/gamification/gamification.dart';
import 'package:mishka_app/features/home/presentation/screens/home_screen.dart';
import 'package:mishka_app/features/our_community/our_community.dart';
import 'package:mishka_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mishka_app/features/saved/presentation/screens/saved_screen.dart';
import 'package:mishka_app/features/home/data/daily_streak_ping.dart';
import 'package:mishka_app/features/study_with_me/presentation/widgets/floating_timer_bar.dart';
import 'package:mishka_app/features/study_with_me/study_with.dart';
import 'package:mishka_app/features/todo_lists/presentation/view/todo_lists_screen.dart';

enum MainTab {
  home,
  todo,
  category,
  saved,
  profile,
}

enum CategoryScreenType {
  main,
  aiTools,
  studyWithMe,
  ourCommunity,
  gamefaction,
  chatWithMishka,
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainTab currentTab = MainTab.home;

  CategoryScreenType categoryScreen = CategoryScreenType.main;
  bool _focusSavedCommunities = false;

  @override
  void initState() {
    super.initState();
    DailyStreakPing().recordAppOpenIfNeeded();
  }

  void switchTab(MainTab tab) {
    setState(() {
      currentTab = tab;
      if (tab != MainTab.category) {
        categoryScreen = CategoryScreenType.main;
        _focusSavedCommunities = false;
      }
    });
  }

  void openCategoryScreen(
    CategoryScreenType screen, {
    bool focusSavedCommunities = false,
  }) {
    setState(() {
      currentTab = MainTab.category;
      categoryScreen = screen;
      _focusSavedCommunities =
          focusSavedCommunities && screen == CategoryScreenType.ourCommunity;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (currentTab) {
      case MainTab.home:
        body = HomeScreen(
          onTabSwitch: switchTab,
          onCategoryNavigate: openCategoryScreen,
        );
        break;
      case MainTab.todo:
        body = const TodoScreen();
        break;
      case MainTab.category:
        body = CategoryContainer(
          screen: categoryScreen,
          onNavigate: openCategoryScreen,
          onTabSwitch: switchTab,
          scrollCommunityToSaved: _focusSavedCommunities,
        );
        break;
      case MainTab.saved:
        body = const SavedScreen();
        break;
      case MainTab.profile:
        body = const ProfileScreen();
        break;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: body),
          const FloatingTimerBar(),
        ],
      ),
      bottomNavigationBar: MishkaBottomNav(
        currentIndex: currentTab.index,
        onTap: (i) => switchTab(MainTab.values[i]),
      ),
    );
  }
}

class CategoryContainer extends StatelessWidget {
  final CategoryScreenType screen;
  final void Function(
    CategoryScreenType screen, {
    bool focusSavedCommunities,
  }) onNavigate;
  final void Function(MainTab)? onTabSwitch;
  final bool scrollCommunityToSaved;

  const CategoryContainer({
    super.key,
    required this.screen,
    required this.onNavigate,
    this.onTabSwitch,
    this.scrollCommunityToSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case CategoryScreenType.main:
        return CategoryScreen(
          onNavigate: onNavigate,
          onTabSwitch: onTabSwitch,
        );

      case CategoryScreenType.aiTools:
        return AiToolsScreen(
          onBack: () => onNavigate(CategoryScreenType.main),
          onNavigate: onNavigate,
        );

      case CategoryScreenType.studyWithMe:
        return StudyWithMishka(
          onBack: () => onNavigate(CategoryScreenType.main),
        );

      case CategoryScreenType.ourCommunity:
        return OurCommunity(
          onBack: () => onNavigate(CategoryScreenType.main),
          scrollToSaved: scrollCommunityToSaved,
        );

      case CategoryScreenType.gamefaction:
        return Gamification(
          onBack: () => onNavigate(CategoryScreenType.main),
        );

      case CategoryScreenType.chatWithMishka:
        return ChatWithMishkaScreen(
          onBack: () => onNavigate(CategoryScreenType.main),
        );
    }
  }
}
