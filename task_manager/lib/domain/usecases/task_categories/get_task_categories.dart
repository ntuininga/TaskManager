import 'package:task_manager/core/usecase/usecase.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class GetTaskCategoriesUseCase implements UseCase<List<TaskCategory>, void> {
  final TaskRepository _taskRepository;

  GetTaskCategoriesUseCase(this._taskRepository);

  @override
  Future<List<TaskCategory>> call({void params}) {
    return _taskRepository.getAllCategories();
  }
}
