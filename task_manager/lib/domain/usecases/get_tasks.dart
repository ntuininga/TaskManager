import 'package:task_manager/core/usecase/usecase.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class GetTaskUseCase implements UseCase<List<Task>,void> {
  final TaskRepository _taskRepository;

  GetTaskUseCase(this._taskRepository);

  @override
  Future<List<Task>> call({void params}) {
    return _taskRepository.getAllTasks();
  }
}