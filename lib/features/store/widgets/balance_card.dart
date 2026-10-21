import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Saldo disponible: 240 monedas',
              child: const ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TU SALDO',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.gold,
                          size: 22,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '240',
                          style: TextStyle(
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
