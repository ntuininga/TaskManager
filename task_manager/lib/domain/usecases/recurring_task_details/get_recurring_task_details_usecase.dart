import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class GetRecurringTaskDetailsUseCase {
  final RecurringTaskRepository repository;

  GetRecurringTaskDetailsUseCase(this.repository);

  Future<RecurringTaskDetails?> call(int taskId) async {
    return await repository.fetchDetailsByTaskId(taskId);
  }
}
