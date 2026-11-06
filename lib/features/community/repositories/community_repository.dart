import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../models/community_post.dart' as model_spec show DiagramPreviewType;

class CommunityRepository {
  final _supabase = Supabase.instance.client;

  Future<List<CommunityPost>> getPosts() async {
    try {
      final List<dynamic> response = await _supabase
          .from('community_posts')
          .select('''
            id,
            caption,
            likes_count,
            comments_count,
            created_at,
            profiles ( display_name, role ),
            diagrams ( title, kind, decision_label, process_label )
          ''')
          .order('created_at', ascending: false);

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
          diagram: DiagramSpec(
            type: _parseDiagramType(diagram['kind']),
            decisionLabel: diagram['decision_label'] ?? 'Es > 0',
            processLabel: diagram['process_label'] ?? 'Mostrar mensaje',
          ), 
        );
      }).toList();
    } catch (error) {
      debugPrint('🚨 Error obteniendo posts: $error');
      rethrow;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'FL';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _generateColor(String name) {
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF8B5CF6),
      const Color(0xFF10B981), const Color(0xFFF59E0B),
    ];
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