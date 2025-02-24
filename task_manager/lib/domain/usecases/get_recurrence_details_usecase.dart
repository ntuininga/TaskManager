import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class GetRecurrenceDetailsUsecase {
  final RecurringTaskRepository repository;

  GetRecurrenceDetailsUsecase(this.repository);

  Future<RecurringTaskDetails> call(int taskId) async {
    RecurringTaskDetails details =
        await repository.fetchDetailsByTaskId(taskId);
    return details;
  }
}
