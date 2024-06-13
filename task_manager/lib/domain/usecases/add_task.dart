import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<Task> call(Task task) async {
    Task addedTask = await repository.addTask(task);

    return addedTask;
  }
}
