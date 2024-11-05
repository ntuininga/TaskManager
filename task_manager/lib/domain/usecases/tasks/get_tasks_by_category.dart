import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class GetTasksByCategoryUseCase {
  final TaskRepository _taskRepository;

  GetTasksByCategoryUseCase(this._taskRepository);

  Future<List<Task>> call(int categoryId) {
    return _taskRepository.getTasksByCategory(categoryId);
  }
}
