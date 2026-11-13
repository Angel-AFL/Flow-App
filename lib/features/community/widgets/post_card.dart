import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/community_post.dart';
import '../repositories/community_repository.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;
  final Function(String) onFeedback;

  const PostCard({
    super.key,
    required this.post,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Avatar, Nombre, Ubicación)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: post.avatarColor,
                  radius: 18,
                  child: Text(post.authorInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                      if (post.location != null && post.location!.isNotEmpty)
                        Text(post.location!, style: const TextStyle(color: Colors.white70, fontSize: 11))
                      else
                        Text(post.authorRole, style: const TextStyle(color: AppColors.secondary, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary), onPressed: () => onFeedback('Opciones del post'), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ),

          // 2. CONTENIDO VISUAL (FOTO O DIAGRAMA)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Image.network(
              post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDiagramFallback(),
            )
          else
            _buildDiagramFallback(),

          // 3. BARRA DE ACCIONES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary, size: 26), onPressed: () => onFeedback('Te gusta esta publicación')),
                IconButton(icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textPrimary, size: 24), onPressed: () => _showCommentsBottomSheet(context, post)),
                IconButton(icon: const Icon(Icons.change_circle_outlined, color: AppColors.textPrimary, size: 26), onPressed: () => _showRemixBottomSheet(context, post)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary, size: 26), onPressed: () => onFeedback('Guardado en colecciones')),
              ],
            ),
          ),

          // 4. CAPTION Y COMENTARIOS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${post.likes} Me gusta', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.3),
                    children: [
                      TextSpan(text: '${post.authorName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (post.comments > 0)
                  GestureDetector(
                    onTap: () => _showCommentsBottomSheet(context, post),
                    child: Text('Ver los ${post.comments} comentarios', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                const SizedBox(height: 4),
                Text(post.timeAgo.toUpperCase(), style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramFallback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        image: const DecorationImage(image: AssetImage('assets/images/grid_pattern.png'), repeat: ImageRepeat.repeat, opacity: 0.2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Text(post.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          _buildMockDiagram(post.diagram),
        ],
      ),
    );
  }

  Widget _buildMockDiagram(DiagramSpec spec) {
    List<Widget> children = [];
    children.add(_buildNode('Inicio', AppColors.secondary, isPill: true));
    children.add(_buildConnector());
    if (spec.type == DiagramPreviewType.decision) {
      children.add(_buildNode(spec.decisionLabel, const Color(0xFF8B5CF6), isDiamond: true));
    } else {
      children.add(_buildNode(spec.processLabel, const Color(0xFF10B981)));
    }
    children.add(_buildConnector());
    children.add(_buildNode('Fin', AppColors.secondary, isPill: true));
    return Column(children: children);
  }

  Widget _buildNode(String text, Color color, {bool isPill = false, bool isDiamond = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDiamond ? 16 : 24, vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(isPill ? 30 : 8), border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildConnector() {
    return Container(width: 2, height: 20, color: Colors.white.withValues(alpha: 0.3));
  }
}

// =========================================================================
// MODALES (BOTTOM SHEETS PARA COMENTAR Y HACER FORK/REMIX)
// =========================================================================

void _showCommentsBottomSheet(BuildContext context, CommunityPost post) {
  final CommunityRepository repo = CommunityRepository();
  final TextEditingController commentController = TextEditingController();
  
  showModalBottomSheet(
    context: context, 
    isScrollControlled: true, 
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(modalContext).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              const Divider(color: Colors.white10, height: 32),
              
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: repo.getComments(post.id),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Sé el primero en comentar.', style: TextStyle(color: Colors.grey)));
                    
                    return ListView.builder(
                      itemCount: snapshot.data!.length, 
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (listCtx, index) {
                        final c = snapshot.data![index];
                        final author = c['profiles']?['display_name'] ?? 'Usuario';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 14, backgroundColor: AppColors.secondary, child: Text(author[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(c['content'], style: const TextStyle(fontSize: 14, color: Colors.white70)),
                                ]),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController, 
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Añadir un comentario...', 
                          hintStyle: const TextStyle(color: Colors.grey), 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), 
                          filled: true, 
                          fillColor: Colors.black26, 
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.secondary),
                      onPressed: () async {
                        if (commentController.text.trim().isEmpty) return;
                        await repo.addComment(post.id, commentController.text.trim());
                        if (modalContext.mounted) {
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comentario publicado')));
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

void _showRemixBottomSheet(BuildContext context, CommunityPost post) {
  final CommunityRepository repo = CommunityRepository();
  
  showModalBottomSheet(
    context: context, 
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (modalContext) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.change_circle_outlined, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text('Hacer Fork (Remix)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Al hacer un Fork, se copiará el diagrama "${post.title}" a tu biblioteca personal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary, 
                  foregroundColor: Colors.black, 
                  padding: const EdgeInsets.symmetric(vertical: 14), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () async {
                  final kindStr = post.diagram.type == DiagramPreviewType.decision ? 'decision' : 'linear';
                  await repo.remixDiagram(post.title, kindStr);
                  if (modalContext.mounted) {
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Diagrama copiado a "Mis diagramas"!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Clonar a Mis Diagramas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}