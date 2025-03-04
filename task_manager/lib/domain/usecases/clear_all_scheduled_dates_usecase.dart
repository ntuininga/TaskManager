import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class ClearScheduledDatesUseCase {
  final RecurringTaskRepository repository;

  ClearScheduledDatesUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.clearAllScheduledDates(id);
  }
}
