import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/features/problems/views/problems_view.dart';
import 'package:codeforcers/features/materials/views/resources_view.dart';
import 'package:codeforcers/features/shell/views/today_view.dart';
import 'package:codeforcers/features/user_details/views/user_details_view.dart';
import 'package:flutter/material.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  static const int _tabCount = 4;

  static const int todayTab = 0;
  static const int problemsTab = 1;
  static const int learnTab = 2;
  static const int profileTab = 3;

  int _index = todayTab;

    final List<Widget?> _tabs = List<Widget?>.filled(_tabCount, null);

  void goToTab(int index) {
    if (index == _index || index < 0 || index >= _tabCount) return;
    setState(() => _index = index);
  }

  Widget _buildTab(int index) {
    final cached = _tabs[index];
    if (cached != null) return cached;

            if (index != _index) return const SizedBox.shrink();

    final Widget tab = switch (index) {
      problemsTab => const ProblemsView(),
      learnTab => const ResourcesView(),
      profileTab => const UserDetailsView(),
      _ => TodayView(onOpenTab: goToTab),
    };

    _tabs[index] = tab;
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: List.generate(_tabCount, _buildTab),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goToTab,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.navy.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Problems',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
