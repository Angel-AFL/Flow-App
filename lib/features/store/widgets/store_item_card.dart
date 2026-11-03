import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/diagram_spec.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/diagram_preview.dart';
import '../models/store_models.dart';

class StoreItemCard extends StatelessWidget {
  const StoreItemCard({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onPurchase,
    required this.onEquip,
    required this.onUse,
  });

  final StoreItem item;
  final bool isBusy;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final rarity = _rarityStyle(item.rarity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.equipped
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.border.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 96, child: _ItemPreview(item: item)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rarity.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: rarity.color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            rarity.label,
                            style: TextStyle(
                              color: rarity.color,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null &&
                        item.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (item.category == StoreItemCategory.consumable &&
                        item.owned) ...[
                      const SizedBox(height: 5),
                      Text(
                        'En tu inventario: ${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _PriceLabel(item: item)),
              const SizedBox(width: 8),
              _ActionButton(
                item: item,
                isBusy: isBusy,
                onPurchase: onPurchase,
                onEquip: onEquip,
                onUse: onUse,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.category) {
      StoreItemCategory.skin => DiagramPreview(
        diagram: const DiagramSpec(type: DiagramPreviewType.linear),
        skin: item.skin!,
        height: 74,
      ),
      StoreItemCategory.diagram => DiagramPreview(
        diagram: item.template!,
        height: 74,
      ),
      StoreItemCategory.title => _TitlePreview(item: item),
      StoreItemCategory.consumable => _ConsumablePreview(item: item),
    };
  }
}

class _TitlePreview extends StatelessWidget {
  const _TitlePreview({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.title!;

    return Container(
      height: 74,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: title.color.withValues(alpha: 0.4)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: title.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: title.color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(title.icon, color: title.color, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: title.color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumablePreview extends StatelessWidget {
  const _ConsumablePreview({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final isBoost = item.consumable?.effect == ConsumableEffect.xpBoost;

    return Container(
      height: 74,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (isBoost ? AppColors.secondary : AppColors.streak).withValues(
            alpha: 0.14,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: (isBoost ? AppColors.secondary : AppColors.streak)
                .withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          isBoost ? Icons.bolt_rounded : Icons.ac_unit_rounded,
          color: isBoost ? AppColors.secondary : AppColors.streak,
          size: 24,
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    if (item.equipped) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              'Equipado',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    if (item.owned && item.category == StoreItemCategory.consumable) {
      return Text(
        'Tienes ${item.quantity}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    if (item.owned) {
      return const Text(
        'Comprado',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.monetization_on_rounded,
          color: AppColors.gold,
          size: 14,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            item.price == 0 ? 'Gratis' : formatThousands(item.price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.isBusy,
    required this.onPurchase,
    required this.onEquip,
    required this.onUse,
  });

  final StoreItem item;
  final bool isBusy;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final (label, onPressed) = _action();

    return SizedBox(
      width: 92,
      height: 36,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: item.equipped
              ? AppColors.surfaceElevated
              : item.owned
              ? AppColors.secondary
              : AppColors.primary,
          foregroundColor: item.owned
              ? AppColors.onPrimary
              : AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: isBusy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }

  (String, VoidCallback?) _action() {
    if (item.equipped) {
      return ('Equipado', null);
    }

    if (item.owned) {
      return switch (item.category) {
        StoreItemCategory.skin ||
        StoreItemCategory.title => ('Equipar', onEquip),
        StoreItemCategory.diagram => ('Añadir', onUse),
        StoreItemCategory.consumable => ('Usar', onUse),
      };
    }

    return ('Comprar', onPurchase);
  }
}

({String label, Color color}) _rarityStyle(StoreRarity rarity) {
  return switch (rarity) {
    StoreRarity.common => (label: 'COMÚN', color: AppColors.textMuted),
    StoreRarity.rare => (label: 'RARO', color: AppColors.secondary),
    StoreRarity.epic => (label: 'ÉPICO', color: const Color(0xFFA78BFA)),
    StoreRarity.legendary => (label: 'LEGENDARIO', color: AppColors.gold),
  };
}
