import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/welcome/welcome_screen.dart';

class FlowApp extends StatelessWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const WelcomeScreen(),
    );
  }
}
