class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;

  String get initials {
    final localPart = email.split('@').first;
    final parts = localPart
        .split(RegExp(r'[._\-+]'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure(${code ?? 'unknown'}): $message';
}

enum SignUpResult { signedIn, confirmationRequired }

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
