abstract final class AuthValidators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Ingresa tu correo.';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }

    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    return null;
  }

  static String? newPassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Crea una contraseña.';
    }

    if (password.length < 8) {
      return 'Usa al menos 8 caracteres.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) {
      return 'Repite la contraseña.';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }
}
