import '../models/learning_models.dart';

class LearningFailure implements Exception {
  const LearningFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'LearningFailure(${code ?? 'unknown'}): $message';
}

abstract interface class LearningRepository {
  Future<LearningSnapshot> loadLearningPath(String userId);

  Future<LessonCompletionResult> completeLesson({
    required String lessonId,
    required DateTime localDate,
  });
}
