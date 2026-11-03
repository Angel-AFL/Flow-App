import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../features/community/community_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/store/store_screen.dart';
import '../../shared/widgets/flow_background.dart';
import '../../shared/widgets/flow_bottom_nav.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user, required this.onSignOut});

  final AppUser user;
  final Future<void> Function() onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const LearnScreen(),
    const CommunityScreen(),
    const StoreScreen(),
    ProfileScreen(userEmail: widget.user.email, onSignOut: widget.onSignOut),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FlowBackground(),
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),
      bottomNavigationBar: FlowBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
