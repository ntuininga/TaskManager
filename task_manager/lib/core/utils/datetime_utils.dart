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
    return date.year == today.year ||
        date.year < today.year && date.month == today.month ||
        date.month < today.month && date.day < today.day;
  }
  return false;
}
