import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../models/store_models.dart';

class PurchaseSheet extends StatelessWidget {
  const PurchaseSheet({super.key, required this.item, required this.coins});

  final StoreItem item;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final canAfford = item.price <= coins;
    final remaining = coins - item.price;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(
                    _iconFor(item.category),
                    color: AppColors.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirmar compra',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.description != null &&
                item.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.description!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Precio',
              value: item.price == 0
                  ? 'Gratis'
                  : '${formatThousands(item.price)} monedas',
              valueColor: AppColors.gold,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Saldo actual',
              value: '${formatThousands(coins)} monedas',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Saldo después',
              value:
                  '${formatThousands(remaining < 0 ? 0 : remaining)} monedas',
              valueColor: canAfford ? AppColors.primary : AppColors.streak,
            ),
            if (!canAfford) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.streak.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.streak,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tienes suficientes monedas. Completa lecciones '
                        'o reclama el cofre diario.',
                        style: TextStyle(
                          color: AppColors.streak,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: canAfford
                    ? () => Navigator.of(context).pop(true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.surfaceElevated,
                  disabledForegroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(
                  canAfford
                      ? 'Comprar por ${formatThousands(item.price)}'
                      : 'Saldo insuficiente',
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(StoreItemCategory category) {
    return switch (category) {
      StoreItemCategory.skin => Icons.palette_outlined,
      StoreItemCategory.title => Icons.military_tech_outlined,
      StoreItemCategory.diagram => Icons.account_tree_outlined,
      StoreItemCategory.consumable => Icons.bolt_outlined,
    };
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
