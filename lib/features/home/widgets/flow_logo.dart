import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FlowLogo extends StatelessWidget {
  const FlowLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FlowApp',
      image: true,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ).createShader(bounds),
        child: Icon(
          Icons.account_tree_rounded,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}
