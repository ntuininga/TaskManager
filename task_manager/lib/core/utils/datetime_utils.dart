import 'package:task_manager/core/frequency.dart';
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

DateTime getNextRecurringDate(DateTime currentDate, Frequency rule) {
  switch (rule) {
    case Frequency.daily:
      return currentDate.add(const Duration(days: 1));
    case Frequency.weekly:
      return currentDate.add(const Duration(days: 7));
    case Frequency.monthly:
      int nextMonth = currentDate.month + 1;
      int yearAdjustment = nextMonth > 12 ? 1 : 0;
      nextMonth = nextMonth > 12 ? nextMonth - 12 : nextMonth;

      int day = currentDate.day;
      int nextYear = currentDate.year + yearAdjustment;

      // Ensure day doesn't exceed the number of days in the next month
      int daysInTargetMonth = DateTime(nextYear, nextMonth, 0).day;
      if (day > daysInTargetMonth) {
        day = daysInTargetMonth;
      }

      return DateTime(nextYear, nextMonth, day);
    case Frequency.yearly:
      return DateTime(
        currentDate.year + 1, 
        currentDate.month, 
        currentDate.day,
      );
    default:
      throw Exception('Unsupported recurring rule');
  }
}

