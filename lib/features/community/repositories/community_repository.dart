import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/community_post.dart';
import '../models/community_post.dart' as model_spec show DiagramPreviewType;

class CommunityRepository {
  final _supabase = Supabase.instance.client;

  Future<List<CommunityPost>> getPosts() async {
    try {
      final List<dynamic> response = await _supabase
          .from('community_posts')
          .select('id, caption, likes_count, comments_count, created_at, image_url, location, profiles ( display_name, role ), diagrams ( title, kind, decision_label, process_label )')
          .order('created_at', ascending: false);
      return _mapPosts(response);
    } catch (e) {
      debugPrint('🚨 Error obteniendo posts generales: $e');
      rethrow;
    }
  }

  Future<List<CommunityPost>> getFollowingPosts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      final follows = await _supabase.from('user_follows').select('following_id').eq('follower_id', userId);
      if (follows.isEmpty) return [];
      final followedIds = follows.map((f) => f['following_id']).toList();

      final List<dynamic> response = await _supabase
          .from('community_posts')
          .select('id, caption, likes_count, comments_count, created_at, image_url, location, profiles ( display_name, role ), diagrams ( title, kind, decision_label, process_label )')
          .inFilter('user_id', followedIds)
          .order('created_at', ascending: false);
      return _mapPosts(response);
    } catch (e) {
      debugPrint('🚨 Error obteniendo posts de seguidos: $e');
      return [];
    }
  }

  Future<List<dynamic>> getSuggestedUsers() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final follows = await _supabase.from('user_follows').select('following_id').eq('follower_id', userId);
    final followedIds = follows.map((f) => f['following_id']).toSet();
    followedIds.add(userId);
    final profiles = await _supabase.from('profiles').select('id, display_name, role');
    return profiles.where((p) => !followedIds.contains(p['id'])).take(5).toList();
  }

  Future<void> followUser(String targetUserId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesión no encontrada');
    await _supabase.from('user_follows').insert({'follower_id': userId, 'following_id': targetUserId});
  }

  Future<List<dynamic>> getWorkshopChallenges() async {
    return await _supabase.from('workshop_challenges').select('id, title, description, difficulty, color_hex, icon_code, profiles(display_name)').order('created_at', ascending: false);
  }

  Future<List<dynamic>> getComments(String postId) async {
    return await _supabase.from('community_comments').select('id, content, created_at, profiles(display_name)').eq('post_id', postId).order('created_at', ascending: true);
  }

  Future<void> addComment(String postId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Debes iniciar sesión para comentar');
    await _supabase.from('community_comments').insert({'post_id': postId, 'user_id': userId, 'content': content});
  }

  Future<void> remixDiagram(String title, String kind) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesión no encontrada');
    await _supabase.from('diagrams').insert({
      'user_id': userId, 'title': '$title (Remix)', 'kind': kind, 'start_label': 'Inicio', 'process_label': 'Proceso copiado', 'decision_label': 'Condición', 'end_label': 'Fin'
    });
  }

  // =========================================================
  // SUBIR POST CON IMAGEN (COMPATIBLE CON WEB/PC/EMULADOR)
  // =========================================================
  Future<void> createNewPost(String caption, XFile? imageFile, String? location) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Sesión no encontrada');

    String? uploadedImageUrl;

    // Subir imagen si existe
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes(); // Compatible con Web y Escritorio
      final fileExt = imageFile.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.$fileExt';
      
      await _supabase.storage.from('community_media').uploadBinary(fileName, bytes);
      uploadedImageUrl = _supabase.storage.from('community_media').getPublicUrl(fileName);
    }

    // Buscamos un diagrama
    final diagResponse = await _supabase.from('diagrams').select('id').eq('user_id', userId).limit(1);
    String diagramId;
    if (diagResponse.isEmpty) {
      final newDiag = await _supabase.from('diagrams').insert({'user_id': userId, 'title': 'Publicación multimedia', 'kind': 'linear'}).select('id').single();
      diagramId = newDiag['id'];
    } else {
      diagramId = diagResponse[0]['id'];
    }

    // Insertar publicación final
    await _supabase.from('community_posts').insert({
      'user_id': userId,
      'diagram_id': diagramId,
      'caption': caption,
      'image_url': uploadedImageUrl,
      'location': location,
      'likes_count': 0,
      'comments_count': 0
    });
  }

  List<CommunityPost> _mapPosts(List<dynamic> response) {
    return response.map((json) {
      final profile = json['profiles'] ?? {};
      final diagram = json['diagrams'] ?? {};
      final authorName = profile['display_name'] ?? 'Estudiante Flow';
      return CommunityPost(
        id: json['id']?.toString() ?? '',
        authorName: authorName,
        authorInitials: _getInitials(authorName),
        avatarColor: _generateColor(authorName),
        timeAgo: _formatTimeAgo(json['created_at']), 
        authorRole: profile['role'] ?? 'Aprendiz',
        title: diagram['title'] ?? 'Sin título',
        caption: json['caption'] ?? '',
        likes: json['likes_count'] ?? 0,
        comments: json['comments_count'] ?? 0,
        imageUrl: json['image_url'],
        location: json['location'],
        diagram: DiagramSpec(
          type: _parseDiagramType(diagram['kind']),
          decisionLabel: diagram['decision_label'] ?? 'Es > 0',
          processLabel: diagram['process_label'] ?? 'Mostrar mensaje',
        ), 
      );
    }).toList();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'FL';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  Color _generateColor(String name) {
    final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
    return colors[name.length % colors.length];
  }
  model_spec.DiagramPreviewType _parseDiagramType(String? kind) {
    if (kind == 'decision') return model_spec.DiagramPreviewType.decision;
    return model_spec.DiagramPreviewType.linear;
  }
  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Ahora';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Ahora';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} min';
    return 'Ahora';
  }
}