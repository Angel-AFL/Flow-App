import 'diagram_lesson.dart';

class LearningLesson {
  const LearningLesson({
    required this.id,
    required this.unitId,
    required this.number,
    required this.title,
    required this.concept,
    required this.instructions,
    required this.xpReward,
    required this.coinReward,
    required this.blocks,
    required this.sortOrder,
    required this.completed,
  });

  final String id;
  final String unitId;
  final int number;
  final String title;
  final String concept;
  final String instructions;
  final int xpReward;
  final int coinReward;
  final List<DiagramBlock> blocks;
  final int sortOrder;
  final bool completed;

  DiagramLesson toDiagramLesson() {
    return DiagramLesson(
      id: id,
      number: number,
      title: title,
      concept: concept,
      instructions: instructions,
      xpReward: xpReward,
      coinReward: coinReward,
      blocks: blocks,
    );
  }

  LearningLesson copyWith({bool? completed}) {
    return LearningLesson(
      id: id,
      unitId: unitId,
      number: number,
      title: title,
      concept: concept,
      instructions: instructions,
      xpReward: xpReward,
      coinReward: coinReward,
      blocks: blocks,
      sortOrder: sortOrder,
      completed: completed ?? this.completed,
    );
  }
}

class LearningUnit {
  const LearningUnit({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.lessons,
  });

  final String id;
  final String title;
  final String? description;
  final int sortOrder;
  final List<LearningLesson> lessons;

  int get completedLessons =>
      lessons.where((lesson) => lesson.completed).length;

  int get totalLessons => lessons.length;

  bool get isCompleted =>
      lessons.isNotEmpty && completedLessons == totalLessons;

  double get progress {
    if (lessons.isEmpty) {
      return 0;
    }

    return completedLessons / totalLessons;
  }

  List<LearningLesson> get sortedLessons {
    return [...lessons]
      ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
  }

  LearningLesson? get firstPendingLesson {
    for (final lesson in sortedLessons) {
      if (!lesson.completed) {
        return lesson;
      }
    }

    return null;
  }

  LearningUnit copyWith({List<LearningLesson>? lessons}) {
    return LearningUnit(
      id: id,
      title: title,
      description: description,
      sortOrder: sortOrder,
      lessons: lessons ?? this.lessons,
    );
  }
}

class LearningSnapshot {
  const LearningSnapshot({required this.units});

  final List<LearningUnit> units;

  int get totalLessons =>
      units.fold(0, (total, unit) => total + unit.totalLessons);

  int get completedLessons =>
      units.fold(0, (total, unit) => total + unit.completedLessons);

  List<LearningUnit> get sortedUnits {
    return [...units]
      ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
  }

  LearningUnit? get currentUnit {
    final ordered = sortedUnits;

    for (final unit in ordered) {
      if (unit.lessons.isNotEmpty && !unit.isCompleted) {
        return unit;
      }
    }

    for (final unit in ordered.reversed) {
      if (unit.lessons.isNotEmpty) {
        return unit;
      }
    }

    return ordered.isEmpty ? null : ordered.first;
  }

  LearningLesson? get currentLesson {
    final unit = currentUnit;

    if (unit == null) {
      return null;
    }

    return unit.firstPendingLesson;
  }

  bool isUnitUnlocked(LearningUnit unit) {
    final ordered = sortedUnits;
    final index = ordered.indexWhere((entry) => entry.id == unit.id);

    if (index == -1) {
      return false;
    }

    final firstWithLessons = ordered.indexWhere(
      (entry) => entry.lessons.isNotEmpty,
    );

    if (firstWithLessons == -1) {
      return index == 0;
    }

    if (index <= firstWithLessons) {
      return true;
    }

    for (var previous = firstWithLessons; previous < index; previous++) {
      if (!ordered[previous].isCompleted) {
        return false;
      }
    }

    return true;
  }

  bool isLessonUnlocked(LearningLesson lesson) {
    if (lesson.completed) {
      return true;
    }

    LearningUnit? unit;

    for (final entry in sortedUnits) {
      if (entry.id == lesson.unitId) {
        unit = entry;
        break;
      }
    }

    if (unit == null || !isUnitUnlocked(unit)) {
      return false;
    }

    for (final previous in unit.sortedLessons) {
      if (previous.sortOrder < lesson.sortOrder && !previous.completed) {
        return false;
      }
    }

    return true;
  }

  LearningSnapshot copyWith({List<LearningUnit>? units}) {
    return LearningSnapshot(units: units ?? this.units);
  }
}

class LessonCompletionResult {
  const LessonCompletionResult({
    required this.alreadyCompleted,
    required this.xpAwarded,
    required this.coinsAwarded,
    required this.totalXp,
    required this.level,
    required this.nextLevelXp,
    required this.lessonsCompleted,
    required this.streakDays,
    required this.coins,
  });

  final bool alreadyCompleted;
  final int xpAwarded;
  final int coinsAwarded;
  final int totalXp;
  final int level;
  final int nextLevelXp;
  final int lessonsCompleted;
  final int streakDays;
  final int coins;

  factory LessonCompletionResult.fromRow(Map<String, dynamic> row) {
    return LessonCompletionResult(
      alreadyCompleted: row['already_completed'] == true,
      xpAwarded: (row['xp_awarded'] as num?)?.toInt() ?? 0,
      coinsAwarded: (row['coins_awarded'] as num?)?.toInt() ?? 0,
      totalXp: (row['total_xp'] as num?)?.toInt() ?? 0,
      level: (row['level'] as num?)?.toInt() ?? 1,
      nextLevelXp: (row['next_level_xp'] as num?)?.toInt() ?? 500,
      lessonsCompleted: (row['lessons_completed'] as num?)?.toInt() ?? 0,
      streakDays: (row['streak_days'] as num?)?.toInt() ?? 0,
      coins: (row['coins'] as num?)?.toInt() ?? 0,
    );
  }
}
