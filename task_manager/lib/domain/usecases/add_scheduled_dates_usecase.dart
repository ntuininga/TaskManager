import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class AddScheduledDatesUseCase {
  final RecurringTaskRepository repository;

  AddScheduledDatesUseCase(this.repository);

  Future<void> call(int id, List<DateTime> scheduledDates) async {
    await repository.addNewScheduledDates(id, scheduledDates);
  }
}
