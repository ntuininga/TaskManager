import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

List<Task> filterTasks(List<Task> tasks, FilterType filter) {
  switch (filter) {
    case FilterType.uncomplete:
      return tasks.where((task) => !task.isDone).toList();
    case FilterType.completed:
      return tasks.where((task) => task.isDone).toList();
    default:
      return tasks;
  }
}

