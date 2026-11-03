import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/stat_card.dart';
import 'services/profile_image_picker.dart';
import 'widgets/achievements_card.dart';
import 'widgets/activity_heatmap.dart';
import 'widgets/diagram_gallery.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.pickImage,
    this.userEmail,
    required this.onSignOut,
  });

  final PickProfileImage? pickImage;
  final String? userEmail;
  final Future<void> Function() onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;
  bool _isPicking = false;

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
    if (_isPicking) {
      return;
    }

    setState(() => _isPicking = true);

    try {
      final picker = widget.pickImage ?? pickProfileImageFromGallery;
      final bytes = await picker();

      if (!mounted || bytes == null) {
        return;
      }

      setState(() => _avatarBytes = bytes);
      _showFeedback(context, 'Foto de perfil actualizada.');
    } catch (_) {
      if (mounted) {
        _showFeedback(
          context,
          'No se pudo abrir la galería. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  avatarBytes: _avatarBytes,
                  isPicking: _isPicking,
                  email: widget.userEmail,
                  onAvatarTap: _isPicking ? null : _pickAvatar,
                  onThemeTap: () => _showFeedback(
                    context,
                    'El tema claro estará disponible próximamente.',
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '1,250',
                        label: 'XP total',
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '7',
                        label: 'Días de racha',
                        color: AppColors.gold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '8',
                        label: 'Lecciones',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const AchievementsCard(),
                const SizedBox(height: 22),
                const ActivityHeatmap(),
                const SizedBox(height: 22),
                DiagramGallery(
                  onViewAll: () => _showFeedback(
                    context,
                    'La galería completa estará disponible próximamente.',
                  ),
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
    );
  }
}
