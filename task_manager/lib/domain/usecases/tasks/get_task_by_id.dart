import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class GetTaskByIdUseCase {
  final TaskRepository _taskRepository;

  GetTaskByIdUseCase(this._taskRepository);

  Future<Task?> call(int id) {
    return _taskRepository.getTaskById(id);
  }
}
