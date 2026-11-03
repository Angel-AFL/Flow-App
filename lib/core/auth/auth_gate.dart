import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../features/welcome/welcome_screen.dart';
import '../navigation/app_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AppUser? _user;
  late final StreamSubscription<AppUser?> _subscription;

  @override
  void initState() {
    super.initState();
    _user = widget.authRepository.currentUser;
    _subscription = widget.authRepository.authStateChanges.listen((user) {
      if (!mounted) {
        return;
      }
      setState(() => _user = user);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (user == null) {
      return WelcomeScreen(authRepository: widget.authRepository);
    }

    return AppShell(user: user, onSignOut: widget.authRepository.signOut);
  }
}
