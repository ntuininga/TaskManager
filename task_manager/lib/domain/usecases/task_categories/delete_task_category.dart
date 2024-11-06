import 'package:task_manager/domain/repositories/task_repository.dart';

class DeleteTaskCategoryUseCase {
  final TaskRepository taskRepository;

  DeleteTaskCategoryUseCase(this.taskRepository);

  Future<void> call(int id) async {
    await taskRepository.deleteTaskCategory(id);
    final tasksWithCategory = await taskRepository.getTasksByCategory(id);

    for (final task in tasksWithCategory) {
      final updatedTask = task.copyWith(taskCategory: null);
      await taskRepository.updateTask(updatedTask);
    }
  }
}
