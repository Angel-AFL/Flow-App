import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'flow_logo.dart';

class FlowWordmark extends StatelessWidget {
  const FlowWordmark({super.key, this.logoSize = 28, this.textSize = 22});

  final double logoSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowLogo(size: logoSize),
        const SizedBox(width: 8),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.textPrimary, AppColors.primary],
          ).createShader(bounds),
          child: Text(
            'FlowApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: textSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}
