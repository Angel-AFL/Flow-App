import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'models/community_post.dart';
import 'widgets/community_header.dart';
import 'widgets/community_tabs.dart';
import 'widgets/post_card.dart';
import 'repositories/community_repository.dart';
import 'create_post_screen.dart';

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
  late Future<List<Map<String, dynamic>>> _suggestedUsersFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _postsFuture = _repository.getPosts();
        _suggestedUsersFuture = _repository
          .getSuggestedUsers()
          .then((users) => users.cast<Map<String, dynamic>>());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    final tab = CommunityTab.values[index];
    if (tab == _selectedTab) {
      _refreshData();
      return;
    }
    setState(() => _selectedTab = tab);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<CommunityPost>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(60.0), child: Center(child: CircularProgressIndicator(strokeWidth: 3)));
        }
        if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(Icons.auto_awesome_mosaic_outlined, 'Sin publicaciones', 'Sé el primero en publicar un post.');
        }

        return Column(
          children: [
            for (final post in snapshot.data!)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PostCard(key: ValueKey(post.id), post: post, onFeedback: _showFeedback),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _suggestedUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(60.0), child: Center(child: CircularProgressIndicator(strokeWidth: 3)));
        }

        final users = snapshot.data ?? const <Map<String, dynamic>>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Descubre nuevos talentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sigue a creadores para inspirarte con sus soluciones.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            if (users.isEmpty)
              _buildEmptyState(Icons.group_outlined, 'No hay sugerencias', 'Ya sigues a todos los creadores disponibles.')
            else
              for (final user in users)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                        child: Text(
                          user['display_name'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['display_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(user['role'] ?? 'Aprendiz', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        onPressed: () async {
                          await _repository.followUser(user['id']);
                          _showFeedback('Comenzaste a seguir a ${user['display_name']}');
                          _refreshData();
                        },
                        child: const Text('Seguir', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildReelsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _suggestedUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(60.0), child: Center(child: CircularProgressIndicator(strokeWidth: 3)));
        }

        final users = snapshot.data ?? const <Map<String, dynamic>>[];
        if (users.isEmpty) {
          return _buildEmptyState(Icons.video_library_outlined, 'No hay Reels', 'Aún no hay videos para mostrar.');
        }

        final videoTitles = ['Animando un bucle infinito 🔥', 'Mi algoritmo de decisiones 💻', 'Hackeando el sistema en 3 bloques 🚀', 'Tutorial de variables veloces ⚡'];

        return Column(
          children: [
            for (int i = 0; i < users.length; i++)
              Container(
                height: 480,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/grid_pattern.png'),
                    repeat: ImageRepeat.repeat,
                    opacity: 0.3,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.play_circle_fill_rounded, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      height: 200,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16, left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.slow_motion_video_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('REEL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32, right: 12,
                      child: Column(
                        children: [
                          _buildReelAction(Icons.favorite_rounded, '${(i + 1) * 124}'),
                          const SizedBox(height: 20),
                          _buildReelAction(Icons.chat_bubble_rounded, '${(i + 1) * 15}'),
                          const SizedBox(height: 20),
                          _buildReelAction(Icons.send_rounded, 'Share'),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 32, left: 16, right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.secondary,
                                child: Text(users[i]['display_name'].toString()[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 10),
                              Text(users[i]['display_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(60, 28),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  await _repository.followUser(users[i]['id']);
                                  _showFeedback('¡Ahora sigues a ${users[i]['display_name']}!');
                                  _refreshData();
                                },
                                child: const Text('Seguir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            videoTitles[i % videoTitles.length],
                            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          const Text('🎵 Sonido original - FlowApp', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          ],
        );
      },
    );
  }

  Widget _buildReelAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceElevated, border: Border.all(color: Colors.white10)),
              child: Icon(icon, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text('Error: $error', style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          ).then((_) => _refreshData()); 
        },
      ),
      body: SafeArea(
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
                  CommunityTabs(selectedIndex: _selectedTab.index, onChanged: _selectTab),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero)
                              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedTab.index),
                      child: _selectedTab == CommunityTab.forYou
                          ? _buildPostsTab()
                          : _selectedTab == CommunityTab.following
                              ? _buildSuggestionsTab()
                              : _buildReelsTab(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}