import 'package:task_manager/domain/models/recurring_task_details.dart';

abstract class RecurringTaskRepository {
  Future<RecurringTaskDetails> fetchDetailsByTaskId(int taskId);
  Future<List<RecurringTaskDetails>> getAllRecurringTasks();
  Future<void> addNewScheduledDates(int taskId, List<DateTime> newDates);
  Future<void> clearAllScheduledDates(int taskId);
  Future<void> updateScheduledDates(
    int taskId, {
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  });
  Future<void> updateCompletedOnDates(
      int taskId, List<DateTime> completedDates);
  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates);
}
