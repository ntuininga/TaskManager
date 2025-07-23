import 'package:task_manager/core/frequency.dart';
// import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';

DateTime getNextRecurringDate(DateTime lastDate, Frequency frequency) {
  switch (frequency) {
    case Frequency.daily:
      return lastDate.add(const Duration(days: 1));
    case Frequency.weekly:
      return lastDate.add(const Duration(days: 7));
    case Frequency.monthly:
      return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
    case Frequency.yearly:
      return DateTime(lastDate.year + 1, lastDate.month, lastDate.day);
    default:
      throw Exception("Unsupported recurrence type");
  }
}

// List<DateTime> generateRecurringDates(
//     DateTime startDate, RecurrenceRuleset recurrenceRuleset,
//     {int numDates = 7}) {
//   List<DateTime> recurringDates = [];
//   DateTime currentDate = startDate;

//   for (int i = 0; i < numDates; i++) {
//     recurringDates.add(currentDate);
//     currentDate = getNextRecurringDate(currentDate, recurrenceRuleset);
//   }

//   return recurringDates;
// }

// List<DateTime> generateInitialScheduledDates(DateTime startDate,
//     RecurrenceRuleset recurrenceRuleset, int maxOccurrences) {
//   List<DateTime> scheduledDates = [];
//   DateTime currentDate = startDate;

//   for (int i = 0; i < maxOccurrences; i++) {
//     scheduledDates.add(currentDate);
//     currentDate = getNextRecurringDate(currentDate, recurrenceRuleset);
//   }

//   return scheduledDates;
// }
