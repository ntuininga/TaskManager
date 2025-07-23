import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class RemoveScheduledDateUseCase {
  final RecurringTaskRepository repository;

  RemoveScheduledDateUseCase(this.repository);

  Future<void> call(int taskId, DateTime scheduledDate) async {
    await repository.removeScheduledDate(taskId, scheduledDate);
  }
}
