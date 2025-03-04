import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/data/entities/recurrence_ruleset.dart';

DateTime getNextRecurringDate(DateTime lastDate, RecurrenceRuleset ruleset) {
  switch (ruleset.frequency) {
    case Frequency.daily:
      return lastDate.add(const Duration(days: 1));
    case Frequency.weekly:
      return lastDate.add(Duration(days: 7));
    case Frequency.monthly:
      return DateTime(lastDate.year, lastDate.month, lastDate.day);
    case Frequency.yearly:
      return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
    default:
      throw Exception("Unsupported recurrence type");
  }
}

List<DateTime> generateInitialScheduledDates(DateTime startDate, RecurrenceRuleset recurrenceRuleset, int maxOccurrences) {
  List<DateTime> scheduledDates = [];
  DateTime currentDate = startDate;

  for (int i = 0; i < maxOccurrences; i++) {
    scheduledDates.add(currentDate);
    currentDate = getNextRecurringDate(currentDate, recurrenceRuleset);
  }

  return scheduledDates;
}
