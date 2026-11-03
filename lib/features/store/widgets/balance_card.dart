import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.coins,
    required this.canClaimDailyReward,
    required this.isClaiming,
    required this.onClaimDaily,
  });

  final int coins;
  final bool canClaimDailyReward;
  final bool isClaiming;
  final VoidCallback onClaimDaily;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label:
                      'Saldo disponible: ${formatThousands(coins)} monedas Flow',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TU SALDO',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              color: AppColors.gold,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatThousands(coins),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const _CoinStack(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    canClaimDailyReward
                        ? 'Cofre diario listo: +25 monedas'
                        : 'Cofre diario disponible cada 24 h',
                    maxLines: 2,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: canClaimDailyReward && !isClaiming
                      ? onClaimDaily
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: isClaiming
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        )
                      : Text(canClaimDailyReward ? 'Reclamar' : 'En espera'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinStack extends StatelessWidget {
  const _CoinStack();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Moneda Flow',
      child: const SizedBox(
        width: 74,
        height: 66,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 16,
              top: 6,
              child: _Coin(size: 56, color: Color(0xFFB27A00)),
            ),
            Positioned(
              left: 8,
              top: 3,
              child: _Coin(size: 58, color: Color(0xFFDD9F00)),
            ),
            Positioned(left: 0, top: 0, child: _FrontCoin()),
          ],
        ),
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: const Color(0xFF8C5E00), width: 2),
      ),
    );
  }
}

class _FrontCoin extends StatelessWidget {
  const _FrontCoin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD75E), AppColors.gold, Color(0xFFE0A100)],
        ),
        border: Border.all(color: const Color(0xFFB27A00), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Text(
        'F',
        style: TextStyle(
          color: Color(0xFF7A4B00),
          fontSize: 26,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
