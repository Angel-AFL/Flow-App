import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SkinInfo {
  const SkinInfo({required this.name, this.price, this.equipped = false});

  final String name;
  final int? price;
  final bool equipped;
}

class SkinCard extends StatelessWidget {
  const SkinCard({super.key, required this.skin});

  final SkinInfo skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          const _SkinPreview(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                if (skin.equipped)
                  const Text(
                    'Equipada',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.gold,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${skin.price}',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _SeeSkinButton(),
        ],
      ),
    );
  }
}

class _SkinPreview extends StatelessWidget {
  const _SkinPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PreviewNode(label: 'Inicio', width: 34, radius: 999),
          _PreviewConnector(),
          _PreviewNode(label: 'Mostrar mensaje', width: 72, radius: 3),
          _PreviewConnector(),
          _PreviewNode(label: 'Fin', width: 28, radius: 999),
        ],
      ),
    );
  }
}

class _PreviewNode extends StatelessWidget {
  const _PreviewNode({
    required this.label,
    required this.width,
    required this.radius,
  });

  final String label;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 13,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 5.2,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}

class _PreviewConnector extends StatelessWidget {
  const _PreviewConnector();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 4, color: AppColors.border);
  }
}

class _SeeSkinButton extends StatelessWidget {
  const _SeeSkinButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ver skin',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
