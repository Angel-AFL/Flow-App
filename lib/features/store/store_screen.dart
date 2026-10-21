import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_page_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/skin_card.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  static const List<SkinInfo> _skins = [
    SkinInfo(name: 'Clásico', equipped: true),
    SkinInfo(name: 'Pixel Art', price: 120),
    SkinInfo(name: 'Cyber', price: 200),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlowPageHeader(title: 'Tienda Flow'),
                const SizedBox(height: 20),
                const BalanceCard(),
                const SizedBox(height: 24),
                const _StoreSectionHeader(),
                const SizedBox(height: 12),
                for (var index = 0; index < _skins.length; index++) ...[
                  SkinCard(skin: _skins[index]),
                  if (index < _skins.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSectionHeader extends StatelessWidget {
  const _StoreSectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Skins para diagramas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          '3 estilos',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
