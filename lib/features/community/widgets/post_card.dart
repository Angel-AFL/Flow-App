import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/diagram_preview.dart';
import '../models/community_post.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, required this.onFeedback});

  final CommunityPost post;
  final ValueChanged<String> onFeedback;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _liked = false;
    _likeCount = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        void select(String message) {
          Navigator.of(sheetContext).pop();
          widget.onFeedback(message);
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              _MenuOption(
                icon: Icons.person_outline_rounded,
                label: 'Ver perfil',
                onTap: () => select(
                  'Los perfiles públicos estarán disponibles próximamente.',
                ),
              ),
              _MenuOption(
                icon: Icons.ios_share_rounded,
                label: 'Compartir publicación',
                onTap: () =>
                    select('Compartir estará disponible próximamente.'),
              ),
              _MenuOption(
                icon: Icons.flag_outlined,
                label: 'Reportar',
                onTap: () => select(
                  'El reporte de publicaciones estará disponible próximamente.',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          post.avatarColor,
                          Color.lerp(post.avatarColor, Colors.black, 0.3)!,
                        ],
                      ),
                    ),
                    child: Text(
                      post.authorInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${post.timeAgo}  ·  ${post.authorRole}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: 'Opciones de la publicación de ${post.authorName}',
                    child: InkResponse(
                      onTap: () => _openMenu(context),
                      radius: 20,
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textMuted,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: DiagramPreview(diagram: post.diagram),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 13),
              child: Text(
                post.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep.withValues(alpha: 0.35),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  _ActionButton(
                    semanticLabel: _liked
                        ? 'Quitar me gusta, $_likeCount'
                        : 'Me gusta, $_likeCount',
                    onTap: _toggleLike,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(_liked),
                        size: 19,
                        color: _liked
                            ? const Color(0xFFFF6B81)
                            : AppColors.textSecondary,
                      ),
                    ),
                    label: '$_likeCount',
                    labelColor: _liked
                        ? const Color(0xFFFF8FA0)
                        : AppColors.textSecondary,
                  ),
                  _ActionButton(
                    semanticLabel: 'Comentarios, ${post.comments}',
                    onTap: () => widget.onFeedback(
                      'Los comentarios estarán disponibles próximamente.',
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: '${post.comments}',
                    labelColor: AppColors.textSecondary,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => widget.onFeedback(
                      'El Remix estará disponible próximamente.',
                    ),
                    icon: const Icon(Icons.repeat_rounded, size: 17),
                    label: const Text('Remix'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.semanticLabel,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.labelColor,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 21),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      dense: true,
    );
  }
}
