import 'package:flutter/material.dart';

bool isToday(DateTime? date) {
  final today = DateTime.now();

  if (date != null) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
  return false;
}

  String formatTime(TimeOfDay time) {
    final hours = time.hour % 12;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hours == 0 ? 12 : hours}:$minutes $period';
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

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}


extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

int getDaysInMonth(int year, int month) {
  final beginningNextMonth = (month < 12)
      ? DateTime(year, month + 1, 1)
      : DateTime(year + 1, 1, 1);
  final lastDayOfMonth = beginningNextMonth.subtract(const Duration(days: 1));
  return lastDayOfMonth.day;
}

