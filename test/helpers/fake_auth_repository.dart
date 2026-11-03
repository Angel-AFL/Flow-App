import 'dart:async';

import 'package:flow_app/core/auth/auth_repository.dart';

const demoUser = AppUser(id: 'user-1', email: 'estudiante@flow.app');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.user,
    this.signInFailure,
    this.signUpFailure,
    this.signOutFailure,
    this.signUpResult = SignUpResult.signedIn,
  });

  AppUser? user;
  final _controller = StreamController<AppUser?>.broadcast();

  final AuthFailure? signInFailure;
  final AuthFailure? signUpFailure;
  final AuthFailure? signOutFailure;
  final SignUpResult signUpResult;

  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  void emit(AppUser? value) {
    user = value;
    _controller.add(value);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;

    final failure = signInFailure;
    if (failure != null) {
      throw failure;
    }

    emit(AppUser(id: 'user-1', email: email));
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;

    final failure = signUpFailure;
    if (failure != null) {
      throw failure;
    }

    if (signUpResult == SignUpResult.signedIn) {
      emit(AppUser(id: 'user-1', email: email));
    }

    return signUpResult;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;

    final failure = signOutFailure;
    if (failure != null) {
      throw failure;
    }

    emit(null);
  }

  Future<void> dispose() => _controller.close();
}
