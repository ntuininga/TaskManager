import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  Future<Task> call(Task task) async {
    Task addedTask = await repository.addTask(task);
      // TaskCategory category =
      //     await repository.getCategoryById(task.taskCategoryId ?? 0);
      // addedTask = addedTask.copyWith(taskCategory: category);

    return addedTask;
  }
}
