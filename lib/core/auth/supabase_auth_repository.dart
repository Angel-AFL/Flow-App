import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges => _client.auth.onAuthStateChange.map(
    (state) => _mapUser(state.session?.user),
  );

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      throw AuthFailure(_messageFor(error), code: error.code);
    } catch (_) {
      throw const AuthFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión e inténtalo '
        'de nuevo.',
      );
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      return response.session == null
          ? SignUpResult.confirmationRequired
          : SignUpResult.signedIn;
    } on AuthException catch (error) {
      throw AuthFailure(_messageFor(error), code: error.code);
    } catch (_) {
      throw const AuthFailure(
        'No pudimos crear la cuenta. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthFailure(_messageFor(error), code: error.code);
    } catch (_) {
      throw const AuthFailure(
        'No pudimos cerrar la sesión. Inténtalo de nuevo.',
      );
    }
  }

  static AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(id: user.id, email: user.email ?? '');
  }

  static String _messageFor(AuthException error) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Correo o contraseña incorrectos.';
      case 'email_not_confirmed':
        return 'Confirma tu correo antes de iniciar sesión.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak_password':
        return 'La contraseña es demasiado débil. Usa al menos 8 caracteres.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 'signup_disabled':
        return 'El registro está deshabilitado en este momento.';
      case 'email_address_invalid':
        return 'El correo no tiene un formato válido.';
      default:
        return 'No pudimos completar la operación. Inténtalo de nuevo.';
    }
  }
}
