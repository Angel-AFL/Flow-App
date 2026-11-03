import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_page_header.dart';
import 'controllers/wallet_controller.dart';
import 'models/store_models.dart';
import 'repositories/store_repository.dart';
import 'widgets/balance_card.dart';
import 'widgets/purchase_sheet.dart';
import 'widgets/store_category_tabs.dart';
import 'widgets/store_item_card.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({
    super.key,
    required this.userId,
    required this.repository,
    required this.wallet,
    this.refreshToken = 0,
  });

  final String userId;
  final StoreRepository repository;
  final WalletController wallet;
  final int refreshToken;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  StoreSnapshot? _snapshot;
  StoreFailure? _error;
  bool _isLoading = true;
  bool _isClaimingDaily = false;
  String? _busyCode;
  StoreItemCategory _selectedCategory = StoreItemCategory.skin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant StoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshToken != oldWidget.refreshToken) {
      _load(showLoading: false);
    }
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final snapshot = await widget.repository.loadStore(widget.userId);

      if (!mounted) {
        return;
      }

      widget.wallet.updateCoins(snapshot.coins);
      setState(() {
        _snapshot = snapshot;
        _error = null;
        _isLoading = false;
      });
    } on StoreFailure catch (failure) {
      if (!mounted) {
        return;
      }

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(failure.message);
      } else {
        setState(() {
          _error = failure;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      const failure = StoreFailure(
        'No pudimos cargar la tienda. Inténtalo de nuevo.',
      );

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(failure.message);
      } else {
        setState(() {
          _error = failure;
          _isLoading = false;
        });
      }
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _purchase(StoreItem item) async {
    final snapshot = _snapshot;

    if (snapshot == null || _busyCode != null) {
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => PurchaseSheet(item: item, coins: snapshot.coins),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _busyCode = item.code);

    try {
      final result = await widget.repository.purchaseItem(
        userId: widget.userId,
        itemCode: item.code,
      );

      if (!mounted) {
        return;
      }

      final current = _snapshot;
      if (current != null) {
        setState(() {
          _snapshot = current.copyWith(
            coins: result.coins,
            items: current.items
                .map(
                  (entry) => entry.code == item.code
                      ? entry.copyWith(owned: true, quantity: result.quantity)
                      : entry,
                )
                .toList(),
          );
        });
        widget.wallet.updateCoins(result.coins);
      }

      _showFeedback('¡Compraste ${item.name}!');
    } on StoreFailure catch (failure) {
      if (mounted) {
        _showFeedback(failure.message);
      }
    } catch (_) {
      if (mounted) {
        _showFeedback('No pudimos completar la compra. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _busyCode = null);
      }
    }
  }

  Future<void> _equip(StoreItem item) async {
    if (_busyCode != null) {
      return;
    }

    setState(() => _busyCode = item.code);

    try {
      await widget.repository.equipItem(
        userId: widget.userId,
        itemCode: item.code,
      );

      if (!mounted) {
        return;
      }

      final current = _snapshot;
      if (current != null) {
        setState(() {
          _snapshot = current.copyWith(
            items: current.items
                .map(
                  (entry) => entry.category == item.category
                      ? entry.copyWith(equipped: entry.code == item.code)
                      : entry,
                )
                .toList(),
          );
        });
      }

      _showFeedback('${item.name} equipado.');
    } on StoreFailure catch (failure) {
      if (mounted) {
        _showFeedback(failure.message);
      }
    } catch (_) {
      if (mounted) {
        _showFeedback('No pudimos equipar el ítem. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _busyCode = null);
      }
    }
  }

  Future<void> _use(StoreItem item) async {
    if (_busyCode != null) {
      return;
    }

    setState(() => _busyCode = item.code);

    try {
      if (item.category == StoreItemCategory.diagram) {
        await widget.repository.useDiagramTemplate(
          userId: widget.userId,
          itemCode: item.code,
        );

        if (mounted) {
          _showFeedback('Plantilla añadida a Mis diagramas.');
        }
        return;
      }

      final result = await widget.repository.useConsumable(
        userId: widget.userId,
        itemCode: item.code,
      );

      if (!mounted) {
        return;
      }

      final current = _snapshot;
      if (current != null) {
        final consumable = item.consumable;
        setState(() {
          _snapshot = current.copyWith(
            items: current.items
                .map(
                  (entry) => entry.code == item.code
                      ? entry.copyWith(
                          owned: result.remaining > 0,
                          quantity: result.remaining,
                        )
                      : entry,
                )
                .toList(),
            streakFreezes: result.effect == ConsumableEffect.streakFreeze
                ? current.streakFreezes + (consumable?.amount ?? 1)
                : current.streakFreezes,
            xpBoostUntil: result.effect == ConsumableEffect.xpBoost
                ? DateTime.now().add(Duration(hours: consumable?.hours ?? 24))
                : current.xpBoostUntil,
          );
        });
      }

      _showFeedback(
        result.effect == ConsumableEffect.xpBoost
            ? 'XP x2 activado durante 24 h.'
            : 'Congelación de racha añadida.',
      );
    } on StoreFailure catch (failure) {
      if (mounted) {
        _showFeedback(failure.message);
      }
    } catch (_) {
      if (mounted) {
        _showFeedback('No pudimos usar el ítem. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _busyCode = null);
      }
    }
  }

  Future<void> _claimDailyReward() async {
    if (_isClaimingDaily) {
      return;
    }

    setState(() => _isClaimingDaily = true);

    try {
      final result = await widget.repository.claimDailyReward(widget.userId);

      if (!mounted) {
        return;
      }

      final current = _snapshot;
      if (current != null) {
        setState(() {
          _snapshot = current.copyWith(
            coins: result.coins,
            lastDailyRewardAt: DateTime.now(),
          );
        });
        widget.wallet.updateCoins(result.coins);
      }

      _showFeedback('¡Cofre reclamado! +${result.coinsAwarded} monedas.');
    } on StoreFailure catch (failure) {
      if (mounted) {
        _showFeedback(failure.message);
      }
    } catch (_) {
      if (mounted) {
        _showFeedback('No pudimos reclamar el cofre. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() => _isClaimingDaily = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final error = _error;
    final snapshot = _snapshot;

    if (error != null && snapshot == null) {
      return SafeArea(
        child: _StoreError(message: error.message, onRetry: _load),
      );
    }

    if (snapshot == null) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final items = snapshot.itemsFor(_selectedCategory);
    final counts = <StoreItemCategory, int>{
      for (final category in StoreItemCategory.values)
        category: snapshot.itemsFor(category).length,
    };
    final section = _sectionText(_selectedCategory);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _load(showLoading: false),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FlowPageHeader(title: 'Tienda Flow'),
                  const SizedBox(height: 20),
                  BalanceCard(
                    coins: snapshot.coins,
                    canClaimDailyReward: snapshot.canClaimDailyReward,
                    isClaiming: _isClaimingDaily,
                    onClaimDaily: _claimDailyReward,
                  ),
                  if (snapshot.xpBoostActive || snapshot.streakFreezes > 0) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (snapshot.xpBoostActive)
                          const _StatusChip(
                            icon: Icons.bolt_rounded,
                            label: 'XP x2 activo',
                            color: AppColors.secondary,
                          ),
                        if (snapshot.streakFreezes > 0)
                          _StatusChip(
                            icon: Icons.ac_unit_rounded,
                            label:
                                '${snapshot.streakFreezes} congelación(es) de racha',
                            color: AppColors.streak,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  StoreCategoryTabs(
                    selected: _selectedCategory,
                    counts: counts,
                    onChanged: (category) =>
                        setState(() => _selectedCategory = category),
                  ),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: section.$1,
                    subtitle: section.$2,
                    count: items.length,
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const _EmptyCategory()
                  else
                    for (var index = 0; index < items.length; index++) ...[
                      StoreItemCard(
                        key: ValueKey(items[index].code),
                        item: items[index],
                        isBusy: _busyCode == items[index].code,
                        onPurchase: () => _purchase(items[index]),
                        onEquip: () => _equip(items[index]),
                        onUse: () => _use(items[index]),
                      ),
                      if (index < items.length - 1) const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 18),
                  const _EarnCoinsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static (String, String) _sectionText(StoreItemCategory category) {
    return switch (category) {
      StoreItemCategory.skin => (
        'Skins para diagramas',
        'Cambia el aspecto de tus diagramas publicados y de tu galería.',
      ),
      StoreItemCategory.title => (
        'Títulos de perfil',
        'Muestra tu estilo y tus logros junto a tu nombre.',
      ),
      StoreItemCategory.diagram => (
        'Plantillas premium',
        'Añade diagramas listos para editar a tu galería.',
      ),
      StoreItemCategory.consumable => (
        'Extras y consumibles',
        'Potencia tu XP o protege tu racha cuando la necesites.',
      ),
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count ítems',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 28,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 8),
          Text(
            'No hay ítems en esta categoría.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnCoinsCard extends StatelessWidget {
  const _EarnCoinsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.secondary,
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Gana monedas completando lecciones y reclamando tu cofre '
              'diario. Las monedas se guardan en tu perfil.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreError extends StatelessWidget {
  const _StoreError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 34,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No pudimos cargar la tienda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Reintentar'),
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
