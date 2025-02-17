import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class CheckRecurringTasksUseCase {
  final RecurringTaskRepository repository;

  CheckRecurringTasksUseCase(this.repository);

  Future<void> execute() async {
    final tasks = await repository.getAllRecurringTasks();
    final DateTime today = DateTime.now();

    for (var task in tasks) {
      List<DateTime> newDates = _generateNewDates(task, today);
      if (newDates.isNotEmpty) {
        await repository.addNewScheduledDates(task.taskId!, newDates);
      }
    }
  }

  List<DateTime> _generateNewDates(RecurringTaskDetails task, DateTime today) {
    List<DateTime> newDates = [];
    DateTime lastScheduled = task.scheduledDates?.last ?? today;

    while (lastScheduled.isBefore(today)) {
      lastScheduled = lastScheduled.add(Duration(days: 7)); // Example: Weekly
      if (lastScheduled.isBefore(today)) {
        newDates.add(lastScheduled);
      }
    }

    return newDates;
  }
}
