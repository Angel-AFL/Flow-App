import 'package:flutter/material.dart';

import 'core/auth/auth_gate.dart';
import 'core/auth/auth_repository.dart';
import 'core/theme/app_theme.dart';

class FlowApp extends StatelessWidget {
  const FlowApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(authRepository: authRepository),
    );
  }
}
