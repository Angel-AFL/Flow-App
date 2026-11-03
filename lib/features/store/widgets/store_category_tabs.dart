import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/store_models.dart';

class StoreCategoryTabs extends StatelessWidget {
  const StoreCategoryTabs({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final StoreItemCategory selected;
  final Map<StoreItemCategory, int> counts;
  final ValueChanged<StoreItemCategory> onChanged;

  static const _categories = [
    (StoreItemCategory.skin, 'Skins', Icons.palette_outlined),
    (StoreItemCategory.title, 'Títulos', Icons.military_tech_outlined),
    (StoreItemCategory.diagram, 'Plantillas', Icons.account_tree_outlined),
    (StoreItemCategory.consumable, 'Extras', Icons.bolt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < _categories.length; index++) ...[
            _CategoryChip(
              label: _categories[index].$2,
              icon: _categories[index].$3,
              count: counts[_categories[index].$1] ?? 0,
              selected: selected == _categories[index].$1,
              onTap: () => onChanged(_categories[index].$1),
            ),
            if (index < _categories.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $count ítems',
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.65)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
