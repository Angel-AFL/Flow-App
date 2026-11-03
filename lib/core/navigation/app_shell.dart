import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../features/community/community_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_screen.dart';
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
    required this.profileRepository,
    required this.storeRepository,
    required this.onSignOut,
  });

  final AppUser user;
  final ProfileRepository profileRepository;
  final StoreRepository storeRepository;
  final Future<void> Function() onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
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
    HomeScreen(wallet: _wallet),
    LearnScreen(
      userId: widget.user.id,
      repository: widget.storeRepository,
      wallet: _wallet,
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
      if (index == 3) {
        _storeRefreshToken++;
      }
      if (index == 4) {
        _profileRefreshToken++;
      }
      _currentIndex = index;
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
