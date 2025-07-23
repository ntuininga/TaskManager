import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class AddCompletedDateUseCase {
  final RecurringTaskRepository repository;

  AddCompletedDateUseCase(this.repository);

  Future<void> call(int taskId, DateTime completedDate) async {
    await repository.addCompletedDate(taskId, completedDate);
  }
}
