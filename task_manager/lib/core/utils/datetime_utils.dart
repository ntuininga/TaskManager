import 'package:task_manager/data/entities/task_entity.dart';

bool isToday(DateTime? date) {
  final today = DateTime.now();

  if (date != null) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
  return false;
}

bool isOverdue(DateTime? date) {
  final today = DateTime.now();

  if (date != null) {
    // Compare only year, month, and day to exclude today's date.
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final givenDateOnly = DateTime(date.year, date.month, date.day);

    return givenDateOnly.isBefore(todayDateOnly);
  }
  return false;
}

extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

DateTime getNextRecurringDate(DateTime currentDate, RecurrenceType rule) {
  switch (rule) {
    case RecurrenceType.daily:
      return currentDate.add(const Duration(days: 1));
    case RecurrenceType.weekly:
      return currentDate.add(const Duration(days: 7));
    case RecurrenceType.monthly:
      return DateTime(
        currentDate.year,
        currentDate.month + 1,
        currentDate.day,
      );
    case RecurrenceType.yearly:
      return DateTime(
        currentDate.year + 1, 
        currentDate.month, 
        currentDate.day
      );
    default:
      throw Exception('Unsupported recurring rule');
  }
}
