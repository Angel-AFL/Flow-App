import 'package:flutter/material.dart';

import '../store/controllers/wallet_controller.dart';
import 'lesson_screen.dart';
import 'models/learning_models.dart';
import 'repositories/learning_repository.dart';

class LessonFlowResult {
  const LessonFlowResult({
    required this.approved,
    this.completion,
    this.errorMessage,
  });

  final bool approved;
  final LessonCompletionResult? completion;
  final String? errorMessage;
}

Future<LessonFlowResult> runLessonFlow({
  required BuildContext context,
  required LearningLesson lesson,
  required LearningRepository repository,
  required WalletController wallet,
}) async {
  final approved = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => LessonScreen(
        lesson: lesson.toDiagramLesson(),
        isReview: lesson.completed,
      ),
    ),
  );

  if (approved != true) {
    return const LessonFlowResult(approved: false);
  }

  try {
    final completion = await repository.completeLesson(
      lessonId: lesson.id,
      localDate: DateTime.now(),
    );

    wallet.updateCoins(completion.coins);

    return LessonFlowResult(approved: true, completion: completion);
  } on LearningFailure catch (failure) {
    return LessonFlowResult(
      approved: true,
      errorMessage: failure.message,
    );
  } catch (_) {
    return const LessonFlowResult(
      approved: true,
      errorMessage:
          'La lección quedó completada, pero no pudimos guardar el progreso.',
    );
  }
}
