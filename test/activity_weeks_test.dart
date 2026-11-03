import 'package:flutter_test/flutter_test.dart';

import 'package:flow_app/features/profile/utils/activity_weeks.dart';

void main() {
  test('agrupa los últimos 35 días en 5 semanas de 7 días', () {
    final start = DateTime(2026, 10, 5);
    final weeks = buildActivityWeeks(
      countsByDate: const {
        '2026-10-05': 0,
        '2026-10-06': 1,
        '2026-10-07': 3,
        '2026-10-08': 5,
      },
      startMonday: start,
    );

    expect(weeks.length, 5);
    expect(weeks.every((week) => week.length == 7), isTrue);
    expect(weeks[0], [0, 1, 2, 3, 0, 0, 0]);
    expect(weeks[4][6], 0);
  });

  test('convierte la actividad en niveles de intensidad', () {
    expect(activityLevelForCount(0), 0);
    expect(activityLevelForCount(1), 1);
    expect(activityLevelForCount(2), 1);
    expect(activityLevelForCount(3), 2);
    expect(activityLevelForCount(4), 2);
    expect(activityLevelForCount(5), 3);
    expect(activityLevelForCount(12), 3);
  });

  test('la ventana empieza el lunes de hace cuatro semanas', () {
    final start = startOfActivityWindow(DateTime(2026, 11, 2));
    expect(formatDateKey(start), '2026-10-05');
  });
}
