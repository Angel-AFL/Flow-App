import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PasswordToggle extends StatelessWidget {
  const PasswordToggle({
    super.key,
    required this.obscure,
    required this.onPressed,
  });

  final bool obscure;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: AppColors.textMuted,
      ),
    );
  }
}
