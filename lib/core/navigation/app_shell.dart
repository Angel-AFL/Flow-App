import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../features/community/community_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/learn/repositories/learning_repository.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/store/controllers/wallet_controller.dart';
import '../../features/store/repositories/store_repository.dart';
import '../../features/store/store_screen.dart';
import '../../shared/widgets/flow_background.dart';
import '../../shared/widgets/flow_bottom_nav.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.learningRepository,
    required this.profileRepository,
    required this.storeRepository,
    required this.onSignOut,
  });

  final AppUser user;
  final LearningRepository learningRepository;
  final ProfileRepository profileRepository;
  final StoreRepository storeRepository;
  final Future<void> Function() onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  int _homeRefreshToken = 0;
  int _learnRefreshToken = 0;
  int _storeRefreshToken = 0;
  int _profileRefreshToken = 0;
  late final WalletController _wallet;

  @override
  void initState() {
    super.initState();
    _wallet = WalletController(
      repository: widget.storeRepository,
      userId: widget.user.id,
    );
    _wallet.load();
  }

  @override
  void dispose() {
    _wallet.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeScreen(
      userId: widget.user.id,
      wallet: _wallet,
      learningRepository: widget.learningRepository,
      profileRepository: widget.profileRepository,
      refreshToken: _homeRefreshToken,
      onOpenLearn: () => _selectTab(1),
      onOpenProfile: () => _selectTab(4),
      onProgressChanged: _handleProgressChanged,
    ),
    LearnScreen(
      userId: widget.user.id,
      repository: widget.learningRepository,
      wallet: _wallet,
      refreshToken: _learnRefreshToken,
    ),
    const CommunityScreen(),
    StoreScreen(
      key: const PageStorageKey('store'),
      userId: widget.user.id,
      repository: widget.storeRepository,
      wallet: _wallet,
      refreshToken: _storeRefreshToken,
    ),
    ProfileScreen(
      userId: widget.user.id,
      userEmail: widget.user.email,
      repository: widget.profileRepository,
      onSignOut: widget.onSignOut,
      refreshToken: _profileRefreshToken,
    ),
  ];

  void _selectTab(int index) {
    setState(() {
      if (index == 0) {
        _homeRefreshToken++;
      }
      if (index == 1) {
        _learnRefreshToken++;
      }
      if (index == 3) {
        _storeRefreshToken++;
      }
      if (index == 4) {
        _profileRefreshToken++;
      }
      _currentIndex = index;
    });
  }

  void _handleProgressChanged() {
    setState(() {
      _learnRefreshToken++;
      _profileRefreshToken++;
    });
  }

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
        onTap: _selectTab,
      ),
    );
  }
}
