import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'models/community_post.dart';
import 'widgets/community_header.dart';
import 'widgets/community_tabs.dart';
import 'widgets/post_card.dart';
import 'widgets/weekly_workshop_card.dart';

enum CommunityTab { forYou, following, workshop }

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  CommunityTab _selectedTab = CommunityTab.forYou;

  static const Map<CommunityTab, List<CommunityPost>> _postsByTab = {
    CommunityTab.forYou: [
      CommunityPost(
        id: 'codealex-hello-world',
        authorName: 'CodeAlex',
        authorInitials: 'CA',
        avatarColor: AppColors.secondary,
        timeAgo: 'Hace 2 h',
        authorRole: 'Aprendiz',
        title: 'Mi primer diagrama',
        caption: 'Así resolví el ejercicio de Hola mundo.',
        likes: 48,
        comments: 12,
        diagram: DiagramSpec(type: DiagramPreviewType.linear),
      ),
      CommunityPost(
        id: 'logicdev-positive-number',
        authorName: 'LogicDev',
        authorInitials: 'LD',
        avatarColor: Color(0xFF3B82F6),
        timeAgo: 'Hace 2 h',
        authorRole: 'Aprendiz',
        title: '¿Es un número positivo?',
        caption: 'Un pequeño ejemplo utilizando decisiones.',
        likes: 32,
        comments: 12,
        diagram: DiagramSpec(
          type: DiagramPreviewType.decision,
          decisionLabel: 'Es > 0',
        ),
      ),
    ],
    CommunityTab.following: [
      CommunityPost(
        id: 'maracode-count-to-ten',
        authorName: 'MaraCode',
        authorInitials: 'MC',
        avatarColor: Color(0xFF8B5CF6),
        timeAgo: 'Hace 4 h',
        authorRole: 'Aprendiz',
        title: 'Suma hasta 10',
        caption: 'Mi solución con un ciclo corto y fácil de leer.',
        likes: 27,
        comments: 8,
        diagram: DiagramSpec(
          type: DiagramPreviewType.linear,
          processLabel: 'Mostrar número',
        ),
      ),
      CommunityPost(
        id: 'logicdev-positive-number-following',
        authorName: 'LogicDev',
        authorInitials: 'LD',
        avatarColor: Color(0xFF3B82F6),
        timeAgo: 'Ayer',
        authorRole: 'Aprendiz',
        title: '¿Es un número positivo?',
        caption: 'Un pequeño ejemplo utilizando decisiones.',
        likes: 32,
        comments: 12,
        diagram: DiagramSpec(
          type: DiagramPreviewType.decision,
          decisionLabel: 'Es > 0',
        ),
      ),
    ],
    CommunityTab.workshop: [
      CommunityPost(
        id: 'pixelpuzzle-traffic-light',
        authorName: 'PixelPuzzle',
        authorInitials: 'PP',
        avatarColor: Color(0xFFF59E0B),
        timeAgo: 'Hace 1 h',
        authorRole: 'Creador',
        title: 'Reto: semáforo inteligente',
        caption: '¿Puedes resolverlo con menos de cinco bloques?',
        likes: 64,
        comments: 18,
        diagram: DiagramSpec(
          type: DiagramPreviewType.decision,
          decisionLabel: '¿Luz roja?',
        ),
      ),
      CommunityPost(
        id: 'bytemina-number-classifier',
        authorName: 'ByteMia',
        authorInitials: 'BM',
        avatarColor: Color(0xFF10B981),
        timeAgo: 'Hace 5 h',
        authorRole: 'Creadora',
        title: 'Clasifica el número',
        caption: 'Un reto de decisión para practicar condiciones.',
        likes: 41,
        comments: 9,
        diagram: DiagramSpec(
          type: DiagramPreviewType.decision,
          decisionLabel: '¿Es par?',
        ),
      ),
    ],
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    final tab = CommunityTab.values[index];
    if (tab == _selectedTab) {
      return;
    }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _postsByTab[_selectedTab] ?? const <CommunityPost>[];

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
                const SizedBox(height: 16),
                WeeklyWorkshopCard(
                  onTap: () => _showFeedback(
                    'El workshop semanal estará disponible próximamente.',
                  ),
                ),
                const SizedBox(height: 16),
                for (final post in posts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PostCard(
                      key: ValueKey(post.id),
                      post: post,
                      onFeedback: _showFeedback,
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
