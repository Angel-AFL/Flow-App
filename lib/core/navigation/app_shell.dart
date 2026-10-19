import 'package:flutter/material.dart';

import '../../features/home/home_screen.dart';
import '../../features/placeholder/coming_soon_screen.dart';
import '../../shared/widgets/flow_background.dart';
import '../../shared/widgets/flow_bottom_nav.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ComingSoonScreen(
      title: 'Aprender',
      message:
          'La ruta de aprendizaje, las unidades y los retos estarán disponibles pronto.',
      icon: Icons.menu_book_rounded,
    ),
    ComingSoonScreen(
      title: 'Comunidad',
      message:
          'El feed de ejecuciones, los remixes y el workshop llegarán en la siguiente etapa.',
      icon: Icons.groups_rounded,
    ),
    ComingSoonScreen(
      title: 'Tienda',
      message:
          'Las skins, monedas y objetos para personalizar tus diagramas estarán aquí.',
      icon: Icons.shopping_bag_rounded,
    ),
    ComingSoonScreen(
      title: 'Perfil',
      message:
          'Tus logros, estadísticas, heatmap de actividad y diagramas se mostrarán aquí.',
      icon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FlowBackground(),
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),
      bottomNavigationBar: FlowBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
