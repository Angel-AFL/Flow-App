import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/flow_wordmark.dart';
import '../models/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onThemeTap,
    required this.onEditTap,
    this.avatarBytes,
    this.isUpdatingAvatar = false,
    this.onAvatarTap,
    this.email,
  });

  final UserProfile profile;
  final VoidCallback onThemeTap;
  final VoidCallback onEditTap;
  final Uint8List? avatarBytes;
  final bool isUpdatingAvatar;
  final VoidCallback? onAvatarTap;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const FlowWordmark(logoSize: 24, textSize: 19),
            const Spacer(),
            IconButton(
              key: const Key('edit-profile'),
              onPressed: onEditTap,
              tooltip: 'Editar perfil',
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                minimumSize: const Size(42, 42),
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onThemeTap,
              tooltip: 'Cambiar tema',
              icon: const Icon(
                Icons.wb_sunny_outlined,
                size: 19,
                color: AppColors.textSecondary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                minimumSize: const Size(42, 42),
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Semantics(
            button: onAvatarTap != null,
            label:
                'Foto de perfil de ${profile.displayName}. '
                'Toca para cambiarla.',
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('profile-avatar'),
                          onTap: onAvatarTap,
                          customBorder: const CircleBorder(),
                          child: _AvatarVisual(
                            bytes: avatarBytes,
                            url: profile.avatarUrl,
                            initials: profile.initials,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isUpdatingAvatar)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.background.withValues(
                                alpha: 0.65,
                              ),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.background,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera_rounded,
                        size: 12,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '@${profile.username}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const TextSpan(
                text: '  ·  ',
                style: TextStyle(color: AppColors.textMuted),
              ),
              TextSpan(
                text: profile.role,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: profile.equippedTitle.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: profile.equippedTitle.color.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profile.equippedTitle.icon,
                  color: profile.equippedTitle.color,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  profile.equippedTitle.label,
                  style: TextStyle(
                    color: profile.equippedTitle.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (email != null && email!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 2),
        TextButton.icon(
          onPressed: onAvatarTap,
          icon: isUpdatingAvatar
              ? const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                )
              : const Icon(Icons.photo_camera_outlined, size: 15),
          label: Text(
            isUpdatingAvatar ? 'Actualizando foto...' : 'Cambiar foto',
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondary,
            disabledForegroundColor: AppColors.textMuted,
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Nivel ${profile.level}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${formatThousands(profile.xp)} / '
              '${formatThousands(profile.nextLevelXp)} XP',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Semantics(
          label:
              'Progreso al nivel ${profile.level + 1}: '
              '${profile.xp} de ${profile.nextLevelXp} XP',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 7,
              child: ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.16),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: profile.levelProgress,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xFF8FE838)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarVisual extends StatelessWidget {
  const _AvatarVisual({this.bytes, this.url, required this.initials});

  final Uint8List? bytes;
  final String? url;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final data = bytes;

    if (data != null) {
      return Image.memory(
        data,
        key: const Key('profile-avatar-image'),
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
      );
    }

    final avatarUrl = url;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        key: const Key('profile-avatar-image'),
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
      );
    }

    return _InitialsAvatar(initials: initials);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF67C7F5), AppColors.secondary],
        ),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
