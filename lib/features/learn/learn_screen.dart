import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_page_header.dart';
import '../store/controllers/wallet_controller.dart';
import 'lesson_flow.dart';
import 'models/learning_models.dart';
import 'repositories/learning_repository.dart';
import 'widgets/learning_path.dart';
import 'widgets/unit_summary_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.userId,
    required this.repository,
    required this.wallet,
    this.refreshToken = 0,
  });

  final String userId;
  final LearningRepository repository;
  final WalletController wallet;
  final int refreshToken;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  LearningSnapshot? _snapshot;
  LearningFailure? _error;
  bool _isLoading = true;
  String? _busyLessonId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LearnScreen oldWidget) {
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
      final snapshot = await widget.repository.loadLearningPath(widget.userId);

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _error = null;
        _isLoading = false;
      });
    } on LearningFailure catch (failure) {
      if (!mounted) {
        return;
      }

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(failure.message);
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

      const failure = LearningFailure(
        'No pudimos cargar las lecciones. Inténtalo de nuevo.',
      );

      if (!showLoading && _snapshot != null) {
        setState(() => _isLoading = false);
        _showFeedback(failure.message);
      } else {
        setState(() {
          _error = failure;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openLesson(LearningLesson lesson) async {
    if (_busyLessonId != null) {
      return;
    }

    setState(() => _busyLessonId = lesson.id);

    try {
      final flow = await runLessonFlow(
        context: context,
        lesson: lesson,
        repository: widget.repository,
        wallet: widget.wallet,
      );

      if (!mounted || !flow.approved) {
        return;
      }

      final error = flow.errorMessage;
      if (error != null) {
        _showFeedback(error);
        return;
      }

      final result = flow.completion;
      if (result == null) {
        return;
      }

      if (result.alreadyCompleted) {
        _showFeedback('Repaso guardado. Esta lección ya estaba completada.');
      } else {
        _showFeedback(
          'Recompensa: +${result.xpAwarded} XP y '
          '+${result.coinsAwarded} monedas.',
        );
      }

      await _load(showLoading: false);
    } finally {
      if (mounted) {
        setState(() => _busyLessonId = null);
      }
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
          duration: const Duration(seconds: 3),
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
    if (error != null && _snapshot == null) {
      return SafeArea(
        child: _LearnError(message: error.message, onRetry: _load),
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

    final currentUnit = snapshot.currentUnit;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => _load(showLoading: false),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FlowPageHeader(title: 'Ruta de aprendizaje'),
                  const SizedBox(height: 20),
                  if (currentUnit != null)
                    UnitSummaryCard(
                      kicker: 'UNIDAD ${currentUnit.sortOrder}',
                      title: currentUnit.title,
                      progress: currentUnit.progress,
                      completedLessons: currentUnit.completedLessons,
                      totalLessons: currentUnit.totalLessons,
                    ),
                  const SizedBox(height: 18),
                  if (snapshot.totalLessons == 0)
                    const _LearnEmpty()
                  else
                    LearningPath(
                      snapshot: snapshot,
                      busyLessonId: _busyLessonId,
                      onLessonTap: _openLesson,
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

class _LearnError extends StatelessWidget {
  const _LearnError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
                  'No pudimos cargar tus lecciones',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearnEmpty extends StatelessWidget {
  const _LearnEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: const Column(
        children: [
          Icon(Icons.school_outlined, size: 30, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text(
            'Aún no hay lecciones disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
