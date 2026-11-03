import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/models/diagram_skin.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/stat_card.dart';
import 'models/profile_models.dart';
import 'my_diagrams_screen.dart';
import 'repositories/profile_repository.dart';
import 'services/profile_image_picker.dart';
import 'widgets/achievements_card.dart';
import 'widgets/activity_heatmap.dart';
import 'widgets/diagram_gallery.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.repository,
    required this.onSignOut,
    this.pickImage,
    this.refreshToken = 0,
  });

  final String userId;
  final String userEmail;
  final ProfileRepository repository;
  final Future<void> Function() onSignOut;
  final PickProfileImage? pickImage;
  final int refreshToken;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileSnapshot? _snapshot;
  ProfileFailure? _error;
  bool _isLoading = true;
  bool _isUpdatingAvatar = false;
  Uint8List? _avatarPreview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshToken != oldWidget.refreshToken) {
      _load(showLoading: false);
    }
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final snapshot = await widget.repository.loadProfile(widget.userId);

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _error = null;
        _isLoading = false;
        _avatarPreview = null;
      });
    } on ProfileFailure catch (failure) {
      if (!mounted) {
        return;
      }

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(context, failure.message);
      } else {
        setState(() {
          _error = failure;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      const failure = ProfileFailure(
        'No pudimos cargar tu perfil. Inténtalo de nuevo.',
      );

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(context, failure.message);
      } else {
        setState(() {
          _error = failure;
          _isLoading = false;
        });
      }
    }
  }

  void _showFeedback(BuildContext context, String message) {
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

  Future<void> _pickAvatar() async {
    if (_isUpdatingAvatar) {
      return;
    }

    setState(() => _isUpdatingAvatar = true);

    try {
      final picker = widget.pickImage ?? pickProfileImageFromGallery;
      final picked = await picker();

      if (!mounted || picked == null) {
        return;
      }

      setState(() => _avatarPreview = picked.bytes);

      try {
        final result = await widget.repository.uploadAvatar(
          userId: widget.userId,
          image: picked,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          final snapshot = _snapshot;
          if (snapshot != null) {
            _snapshot = snapshot.copyWith(
              profile: snapshot.profile.copyWith(avatarUrl: result.url),
            );
          }
        });
        _showFeedback(context, 'Foto de perfil actualizada.');
      } on ProfileFailure catch (failure) {
        if (mounted) {
          setState(() => _avatarPreview = null);
          _showFeedback(context, failure.message);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _avatarPreview = null);
          _showFeedback(
            context,
            'No se pudo actualizar la foto. Inténtalo de nuevo.',
          );
        }
      }
    } catch (_) {
      if (mounted) {
        _showFeedback(
          context,
          'No se pudo abrir la galería. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAvatar = false);
      }
    }
  }

  Future<void> _editProfile() async {
    final snapshot = _snapshot;

    if (snapshot == null) {
      return;
    }

    final updated = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => EditProfileSheet(
        profile: snapshot.profile,
        onSave: (edit) =>
            widget.repository.updateProfile(userId: widget.userId, edit: edit),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      final current = _snapshot;
      if (current != null) {
        _snapshot = current.copyWith(profile: updated);
      }
    });
    _showFeedback(context, 'Perfil actualizado.');
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await widget.onSignOut();
    } catch (_) {
      if (!mounted || !context.mounted) {
        return;
      }
      _showFeedback(
        context,
        'No se pudo cerrar la sesión. Inténtalo de nuevo.',
      );
    }
  }

  void _openDiagrams() {
    final snapshot = _snapshot;
    final diagrams = snapshot?.diagrams ?? const <ProfileDiagram>[];
    final skin = snapshot?.profile.equippedSkin ?? DiagramSkin.classic;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyDiagramsScreen(diagrams: diagrams, skin: skin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final error = _error;
    if (error != null) {
      return SafeArea(
        child: _ProfileError(
          message: error.message,
          onRetry: _load,
          onSignOut: () => _logout(context),
        ),
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final badges = [
      ...snapshot.achievements.where((achievement) => achievement.unlocked),
      ...snapshot.achievements.where((achievement) => !achievement.unlocked),
    ].take(4).toList();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _load(showLoading: false),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(
                    profile: snapshot.profile,
                    avatarBytes: _avatarPreview,
                    isUpdatingAvatar: _isUpdatingAvatar,
                    email: widget.userEmail,
                    onAvatarTap: _isUpdatingAvatar ? null : _pickAvatar,
                    onEditTap: _editProfile,
                    onThemeTap: () => _showFeedback(
                      context,
                      'El tema claro estará disponible próximamente.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: formatThousands(snapshot.profile.xp),
                          label: 'XP total',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '${snapshot.profile.effectiveStreakDays}',
                          label: 'Días de racha',
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '${snapshot.profile.lessonsCompleted}',
                          label: 'Lecciones',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AchievementsCard(
                    achievements: badges,
                    unlocked: snapshot.unlockedAchievements,
                    total: snapshot.totalAchievements,
                  ),
                  const SizedBox(height: 22),
                  ActivityHeatmap(
                    weeks: snapshot.activityWeeks,
                    hasActivity: snapshot.hasActivity,
                  ),
                  const SizedBox(height: 22),
                  DiagramGallery(
                    diagrams: snapshot.diagrams,
                    skin: snapshot.profile.equippedSkin,
                    onViewAll: _openDiagrams,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Cerrar sesión'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _ProfileError extends StatelessWidget {
  const _ProfileError({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 34,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No pudimos cargar tu perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onSignOut,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    textStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
