import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Task> call(Task task) async {
    Task updatedTask = await repository.updateTask(task);

    return updatedTask;
  }
}
