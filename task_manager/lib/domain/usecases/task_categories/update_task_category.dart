import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class UpdateTaskCategoryUseCase {
  final TaskRepository taskRepository;

  UpdateTaskCategoryUseCase(this.taskRepository);

  Future<void> call(TaskCategory taskCategory) async {
    await taskRepository.updateTaskCategory(taskCategory);
  }
}
