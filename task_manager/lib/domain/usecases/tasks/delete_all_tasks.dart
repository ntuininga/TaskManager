import 'package:task_manager/domain/repositories/task_repository.dart';

class DeleteAllTasksUseCase {
  final TaskRepository repository;

  DeleteAllTasksUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteAllTasks();
  }
}