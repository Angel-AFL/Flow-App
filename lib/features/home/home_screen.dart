import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/stat_card.dart';
import '../learn/lesson_flow.dart';
import '../learn/models/learning_models.dart';
import '../learn/repositories/learning_repository.dart';
import '../profile/models/profile_models.dart';
import '../profile/repositories/profile_repository.dart';
import '../store/controllers/wallet_controller.dart';
import 'widgets/current_route_card.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.userId,
    required this.wallet,
    required this.learningRepository,
    required this.profileRepository,
    required this.onOpenLearn,
    required this.onOpenProfile,
    required this.onProgressChanged,
    this.refreshToken = 0,
  });

  final String userId;
  final WalletController wallet;
  final LearningRepository learningRepository;
  final ProfileRepository profileRepository;
  final VoidCallback onOpenLearn;
  final VoidCallback onOpenProfile;
  final VoidCallback onProgressChanged;
  final int refreshToken;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LearningSnapshot? _learning;
  ProfileStats? _profile;
  String? _error;
  bool _isLoading = true;
  String? _busyLessonId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
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
      final results = await Future.wait<dynamic>([
        widget.learningRepository.loadLearningPath(widget.userId),
        widget.profileRepository.loadStats(widget.userId),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _learning = results[0] as LearningSnapshot;
        _profile = results[1] as ProfileStats;
        _error = null;
        _isLoading = false;
      });
    } on LearningFailure catch (failure) {
      _handleFailure(failure.message, showLoading);
    } on ProfileFailure catch (failure) {
      _handleFailure(failure.message, showLoading);
    } catch (_) {
      _handleFailure(
        'No pudimos cargar tu inicio. Inténtalo de nuevo.',
        showLoading,
      );
    }
  }

  void _handleFailure(String message, bool showLoading) {
    if (!mounted) {
      return;
    }

    if (!showLoading && _learning != null && _profile != null) {
      setState(() => _isLoading = false);
      _showFeedback(message);
    } else {
      setState(() {
        _error = message;
        _isLoading = false;
      });
    }
  }

  Future<void> _continueLesson(LearningLesson? lesson) async {
    if (lesson == null) {
      widget.onOpenLearn();
      return;
    }

    if (_busyLessonId != null) {
      return;
    }

    setState(() => _busyLessonId = lesson.id);

    try {
      final flow = await runLessonFlow(
        context: context,
        lesson: lesson,
        repository: widget.learningRepository,
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

      widget.onProgressChanged();
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
    if (error != null && (_learning == null || _profile == null)) {
      return SafeArea(
        child: _HomeError(message: error, onRetry: _load),
      );
    }

    final learning = _learning;
    final profile = _profile;

    if (learning == null || profile == null) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final currentLesson = learning.currentLesson;

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
                  ListenableBuilder(
                    listenable: widget.wallet,
                    builder: (context, _) => HomeHeader(
                      displayName: profile.displayName,
                      streakDays: profile.effectiveStreakDays,
                      coins: widget.wallet.coins,
                    ),
                  ),
                  const SizedBox(height: 22),
                  CurrentRouteCard(
                    unit: learning.currentUnit,
                    lesson: currentLesson,
                    isBusy: _busyLessonId != null,
                    onContinue: () => _continueLesson(currentLesson),
                    onOpenLearn: widget.onOpenLearn,
                  ),
                  const SizedBox(height: 26),
                  SectionHeader(
                    title: 'Tu progreso',
                    action: 'Ver perfil',
                    onAction: widget.onOpenProfile,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: formatThousands(profile.xp),
                          label: 'XP total',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '${profile.lessonsCompleted}',
                          label: 'Lecciones',
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          value: '${profile.effectiveStreakDays}',
                          label: 'Racha',
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DailyGoalCard(completed: profile.todayActivityCount),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

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
                  'No pudimos cargar tu inicio',
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
