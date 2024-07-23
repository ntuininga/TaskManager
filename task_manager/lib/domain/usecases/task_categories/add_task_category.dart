import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class AddTaskCategoryUseCase {
  final TaskRepository taskRepository;

  AddTaskCategoryUseCase(this.taskRepository);

  Future<void> call(TaskCategory taskCategory) async {
    await taskRepository.addTaskCategory(taskCategory);
  }
}
