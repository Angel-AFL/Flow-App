import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/features/profile/models/profile_models.dart';

import 'helpers/fake_learning_repository.dart';

void main() {
  test('desbloquea las lecciones en orden', () {
    final snapshot = demoLearningSnapshot();
    final lesson4 = snapshot.units.first.lessons.last;

    expect(snapshot.currentLesson?.id, 'unit-1-lesson-3');
    expect(snapshot.isLessonUnlocked(lesson4), isFalse);
    expect(snapshot.isUnitUnlocked(snapshot.units[1]), isFalse);
  });

  test('al completar la unidad se desbloquea la siguiente', () {
    final initial = demoLearningSnapshot();
    final units = initial.units.map((unit) {
      if (unit.id != 'unit-1') {
        return unit;
      }

      return unit.copyWith(
        lessons: unit.lessons
            .map((lesson) => lesson.copyWith(completed: true))
            .toList(),
      );
    }).toList();

    final snapshot = initial.copyWith(units: units);

    expect(snapshot.completedLessons, 4);
    expect(snapshot.currentLesson, isNull);
    expect(snapshot.isUnitUnlocked(snapshot.units[1]), isTrue);
  });

  test('ordena unidades y lecciones aunque lleguen al revés', () {
    final base = demoLearningSnapshot();
    final reversed = base.copyWith(
      units: base.units.reversed
          .map((unit) => unit.copyWith(lessons: unit.lessons.reversed.toList()))
          .toList(),
    );

    expect(reversed.sortedUnits.first.id, 'unit-1');
    expect(
      reversed.sortedUnits.first.sortedLessons.first.id,
      'unit-1-lesson-1',
    );
    expect(reversed.currentLesson?.id, 'unit-1-lesson-3');
    expect(reversed.isUnitUnlocked(reversed.sortedUnits.first), isTrue);
  });

  test('la primera lección está disponible sin progreso previo', () {
    final snapshot = demoFreshLearningSnapshot();
    final unit = snapshot.sortedUnits.first;
    final lessons = unit.sortedLessons;

    expect(snapshot.currentLesson?.id, 'unit-1-lesson-1');
    expect(snapshot.isLessonUnlocked(lessons[0]), isTrue);
    expect(snapshot.isLessonUnlocked(lessons[1]), isFalse);
  });

  test('la barra de nivel usa tramos de 500 XP', () {
    const profile = UserProfile(
      id: 'user-1',
      displayName: 'Estudiante Flow',
      username: 'flowstudent',
      role: 'Aprendiz',
      xp: 250,
      level: 1,
      nextLevelXp: 500,
      streakDays: 1,
      lessonsCompleted: 5,
    );

    expect(profile.levelProgress, 0.5);
  });

  test('la racha se mantiene hoy y ayer, y se reinicia después', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    UserProfile profileWith(DateTime lastActivity) {
      return UserProfile(
        id: 'user-1',
        displayName: 'Estudiante Flow',
        username: 'flowstudent',
        role: 'Aprendiz',
        xp: 50,
        level: 1,
        nextLevelXp: 500,
        streakDays: 7,
        lessonsCompleted: 1,
        lastActivityDate: lastActivity,
      );
    }

    expect(profileWith(today).effectiveStreakDays, 7);
    expect(
      profileWith(today.subtract(const Duration(days: 1))).effectiveStreakDays,
      7,
    );
    expect(
      profileWith(today.subtract(const Duration(days: 2))).effectiveStreakDays,
      0,
    );
  });
}
