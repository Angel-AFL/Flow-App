String formatDateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime startOfActivityWindow(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return monday.subtract(const Duration(days: 28));
}

int activityLevelForCount(int count) {
  if (count <= 0) {
    return 0;
  }
  if (count <= 2) {
    return 1;
  }
  if (count <= 4) {
    return 2;
  }
  return 3;
}

List<List<int>> buildActivityWeeks({
  required Map<String, int> countsByDate,
  required DateTime startMonday,
}) {
  return List.generate(5, (week) {
    return List.generate(7, (weekday) {
      final date = startMonday.add(Duration(days: week * 7 + weekday));
      final count = countsByDate[formatDateKey(date)] ?? 0;
      return activityLevelForCount(count);
    });
  });
}
