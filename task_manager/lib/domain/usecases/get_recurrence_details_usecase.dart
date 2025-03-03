import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class GetRecurrenceDetailsUsecase {
  final RecurringTaskRepository repository;

  GetRecurrenceDetailsUsecase(this.repository);

  Future<RecurringTaskDetails> call(int taskId) async {
    try {
      return await repository.fetchDetailsByTaskId(taskId);
    } catch (e) {
      throw Exception("Failed to fetch recurrence details: $e");
    }
  }
}

