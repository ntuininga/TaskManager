import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

List<Task> filterTasks(
    List<Task> tasks, FilterType filter, TaskCategory? category) {
  switch (filter) {
    case FilterType.uncomplete:
      return tasks.where((task) => !task.isDone).toList();
    case FilterType.completed:
      return tasks.where((task) => task.isDone).toList();
    case FilterType.nodate:
      return tasks.where((task) => task.date == null && !task.isDone).toList();
    case FilterType.overdue:
      return tasks
          .where((task) => isOverdue(task.date) && task.isDone == false)
          .toList();
    case FilterType.urgency:
      return tasks.where((task) => task.urgencyLevel == TaskPriority.high && !task.isDone).toList();
    case FilterType.category:
      return category != null ? filterByCategory(tasks, category) : tasks;
    default:
      return tasks;
  }
}

List<Task> filterByCategory(List<Task> tasks, TaskCategory category) {
  return tasks
      .where((task) => task.taskCategory?.id == category.id && !task.isDone)
      .toList();
}

List<Task> filterUncompletedAndNonRecurring(List<Task> tasks) {
  return tasks.where((task) => !task.isDone && !task.isRecurring).toList();
}
