import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/flow_page_header.dart';
import '../store/controllers/wallet_controller.dart';
import '../store/repositories/store_repository.dart';
import 'lesson_screen.dart';
import 'models/diagram_lesson.dart';
import 'widgets/learning_path.dart';
import 'widgets/unit_summary_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.userId,
    required this.repository,
    required this.wallet,
  });

  final String userId;
  final StoreRepository repository;
  final WalletController wallet;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _lessonCompleted = false;

  Future<void> _openLesson() async {
    final approved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LessonScreen(lesson: firstDiagramLesson),
      ),
    );

    if (!mounted || approved != true) {
      return;
    }

    setState(() => _lessonCompleted = true);

    try {
      final reward = await widget.repository.claimLessonReward(
        userId: widget.userId,
        lessonId: firstDiagramLesson.id,
      );

      if (!mounted) {
        return;
      }

      widget.wallet.updateCoins(reward.coins);

      if (reward.alreadyClaimed) {
        _showFeedback('Ya habías reclamado la recompensa de esta lección.');
      } else {
        _showFeedback(
          'Recompensa: +${reward.coinsAwarded} monedas y '
          '+${reward.xpAwarded} XP.',
        );
      }
    } on StoreFailure catch (failure) {
      if (mounted) {
        _showFeedback(failure.message);
      }
    } catch (_) {
      if (mounted) {
        _showFeedback(
          'La lección quedó completada, pero no pudimos guardar la '
          'recompensa.',
        );
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
    final progress = _lessonCompleted ? 1.0 : 0.67;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlowPageHeader(title: 'Ruta de aprendizaje'),
                const SizedBox(height: 20),
                UnitSummaryCard(
                  progress: progress,
                  completedLessons: _lessonCompleted ? 3 : 2,
                ),
                const SizedBox(height: 18),
                LearningPath(
                  lessonCompleted: _lessonCompleted,
                  onCurrentLessonTap: _openLesson,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
