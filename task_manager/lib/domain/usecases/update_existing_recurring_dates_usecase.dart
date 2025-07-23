import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class UpdateScheduledDatesUseCase {
  final RecurringTaskRepository repository;

  UpdateScheduledDatesUseCase(this.repository);

  Future<void> call({
    required int taskId,
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  }) async {
    await repository.updateScheduledDates(
      taskId,
      newScheduledDates: newScheduledDates,
      newCompletedDates: newCompletedDates,
      newMissedDates: newMissedDates,
    );
  }
}
