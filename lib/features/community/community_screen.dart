import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'models/community_post.dart';
import 'widgets/community_header.dart';
import 'widgets/community_tabs.dart';
import 'widgets/post_card.dart';
import 'widgets/weekly_workshop_card.dart';
import 'repositories/community_repository.dart';

enum CommunityTab { forYou, following, workshop }

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  CommunityTab _selectedTab = CommunityTab.forYou;

  final CommunityRepository _repository = CommunityRepository();
  late Future<List<CommunityPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _repository.getPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    final tab = CommunityTab.values[index];
    if (tab == _selectedTab) return;

    setState(() => _selectedTab = tab);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // =========================================================================
  // VISTAS INDEPENDIENTES POR PESTAÑA
  // =========================================================================

  Widget _buildForYouTab() {
    return FutureBuilder<List<CommunityPost>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.feed_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Feed vacío', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final post in snapshot.data!)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PostCard(
                  key: ValueKey(post.id),
                  post: post,
                  onFeedback: _showFeedback,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    // Empty State profesional para cuando no se sigue a nadie
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline, size: 48, color: AppColors.secondary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aún no sigues a nadie',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descubre creadores en la pestaña "Para ti" y no te pierdas sus diagramas y lógicas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary),
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _selectTab(0),
            child: const Text('Explorar creadores', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildWorkshopTab() {
    // Mocks orientados a retos jugables en cuadrícula, no a publicaciones de redes sociales
    final retos = [
      {'titulo': 'Bucle infinito', 'autor': 'CodeAlex', 'dificultad': 'Media', 'color': 0xFF3B82F6},
      {'titulo': 'Cajero Automático', 'autor': 'ByteMia', 'dificultad': 'Difícil', 'color': 0xFF10B981},
      {'titulo': 'Validador de Edad', 'autor': 'LogicDev', 'dificultad': 'Fácil', 'color': 0xFF8B5CF6},
      {'titulo': 'Máquina de Café', 'autor': 'PixelPuzzle', 'dificultad': 'Experto', 'color': 0xFFF59E0B},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeeklyWorkshopCard(
          onTap: () => _showFeedback('Uniendo al Workshop semanal...'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Retos de la comunidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => _showFeedback('Filtros próximamente'),
              child: const Text('Filtrar', style: TextStyle(color: AppColors.secondary)),
            )
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: retos.length,
          itemBuilder: (context, index) {
            final reto = retos[index];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showFeedback('Cargando nivel: ${reto['titulo']}...'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(reto['color'] as int).withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.extension, color: Color(reto['color'] as int), size: 28),
                    const Spacer(),
                    Text(
                      reto['titulo'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Por ${reto['autor']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(reto['color'] as int).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reto['dificultad'] as String,
                        style: TextStyle(color: Color(reto['color'] as int), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CommunityHeader(),
                const SizedBox(height: 16),
                CommunityTabs(
                  selectedIndex: _selectedTab.index,
                  onChanged: _selectTab,
                ),
                const SizedBox(height: 24),
                
                // Renderizado dinámico de la pestaña seleccionada
                if (_selectedTab == CommunityTab.forYou) _buildForYouTab(),
                if (_selectedTab == CommunityTab.following) _buildFollowingTab(),
                if (_selectedTab == CommunityTab.workshop) _buildWorkshopTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}