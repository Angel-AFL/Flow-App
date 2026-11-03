import 'package:flutter/material.dart';

import 'core/auth/auth_gate.dart';
import 'core/auth/auth_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/repositories/profile_repository.dart';
import 'features/store/repositories/store_repository.dart';

class FlowApp extends StatelessWidget {
  const FlowApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.storeRepository,
  });

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final StoreRepository storeRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(
        authRepository: authRepository,
        profileRepository: profileRepository,
        storeRepository: storeRepository,
      ),
    );
  }
}
