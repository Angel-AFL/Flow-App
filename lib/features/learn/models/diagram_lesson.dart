enum DiagramBlockKind { start, process, decision, end }

enum LessonExerciseKind { order, choice, trace }

class DiagramBlock {
  const DiagramBlock({
    required this.id,
    required this.kind,
    required this.label,
    this.yesLabel,
    this.noLabel,
  });

  final String id;
  final DiagramBlockKind kind;
  final String label;
  final String? yesLabel;
  final String? noLabel;
}

class LessonOption {
  const LessonOption({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagramLesson {
  const DiagramLesson({
    required this.id,
    required this.number,
    required this.title,
    this.concept = '',
    required this.instructions,
    required this.xpReward,
    this.coinReward = 0,
    this.exercise = LessonExerciseKind.order,
    this.blocks = const [],
    this.question = '',
    this.options = const [],
    this.correctOptionId,
    this.explanation = '',
    this.snippet,
  });

  final String id;
  final int number;
  final String title;
  final String concept;
  final String instructions;
  final int xpReward;
  final int coinReward;
  final LessonExerciseKind exercise;
  final List<DiagramBlock> blocks;
  final String question;
  final List<LessonOption> options;
  final String? correctOptionId;
  final String explanation;
  final String? snippet;

  bool get isOrderExercise => exercise == LessonExerciseKind.order;

  bool get isChoiceExercise => exercise != LessonExerciseKind.order;

  bool isCorrect(List<DiagramBlock?> placedBlocks) {
    if (placedBlocks.length != blocks.length) {
      return false;
    }

    for (var index = 0; index < blocks.length; index++) {
      if (placedBlocks[index]?.id != blocks[index].id) {
        return false;
      }
    }

    return true;
  }

  bool isCorrectChoice(String? optionId) {
    return optionId != null && optionId == correctOptionId;
  }

  List<DiagramBlock> get trayBlocks => blocks.reversed.toList();
}
