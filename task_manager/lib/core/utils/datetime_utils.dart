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

extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}


