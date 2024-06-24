
import 'package:task_manager/core/usecase/usecase.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class GetTasksDueToday implements UseCase<List<Task>,void> {
  final TaskRepository _taskRepository;

  GetTasksDueToday(this._taskRepository);

  var today = DateTime.now();

  @override
  Future<List<Task>> call ({void params}) {
    return _taskRepository.getTasksBetweenDates(today, today.add(Duration(days: 1)));
  }
}