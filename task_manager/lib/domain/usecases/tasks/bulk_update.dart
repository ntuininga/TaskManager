import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class BulkUpdateTasksUseCase {
  final TaskRepository repository;

  BulkUpdateTasksUseCase(this.repository);

  Future<void> call(
      List<int> taskIds, TaskCategory? newCategory, bool? markComplete) async {
    await repository.bulkUpdateTasks(taskIds, newCategory, markComplete);
  }
}
