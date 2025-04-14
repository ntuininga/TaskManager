import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

List<Task> filterTasks(
    List<Task> tasks, FilterType filter, TaskCategory? category) {
  List<Task> nonRecurringTasks = filterUncompletedAndNonRecurring(tasks);
  switch (filter) {
    case FilterType.all:
      return nonRecurringTasks;
    case FilterType.uncomplete:
      return nonRecurringTasks.where((task) => !task.isDone).toList();
    case FilterType.completed:
      return tasks.where((task) => task.isDone && !task.isRecurring).toList();
    case FilterType.nodate:
      return nonRecurringTasks
          .where((task) => task.date == null && !task.isDone)
          .toList();
    case FilterType.overdue:
      return filterOverdue(nonRecurringTasks);
    case FilterType.urgency:
      return filterUrgent(nonRecurringTasks);
    case FilterType.category:
      return category != null ? filterByCategory(nonRecurringTasks, category) : tasks;
    case FilterType.dueToday:
      return filterDueToday(nonRecurringTasks);
    case FilterType.recurring:
      return tasks.where((task) => task.isRecurring == true).toList();
    default:
      return tasks;
  }
}

List<Task> filterUrgent(List<Task> tasks) {
  return tasks
      .where((task) => task.urgencyLevel == TaskPriority.high && !task.isDone)
      .toList();
}

List<Task> filterOverdue(List<Task> tasks) {
  return tasks
      .where((task) => isOverdue(task.date) && task.isDone == false)
      .toList();
}

List<Task> filterDueToday(List<Task> tasks) {
  return tasks
      .where((task) =>
          task.date != null &&
          isToday(task.date!) &&
          !task.isDone &&
          !task.isRecurring)
      .toList();
}

List<Task> filterByCategory(List<Task> tasks, TaskCategory category) {
  return tasks
      .where((task) => task.taskCategory?.id == category.id && !task.isDone)
      .toList();
}

List<Task> filterUncompletedAndNonRecurring(List<Task> tasks) {
  return tasks.where((task) => !task.isDone && !task.isRecurring).toList();
}

List<Task> sortTasks(List<Task> tasks, SortType sortType) {
  switch (sortType) {
    case SortType.date:
      return sortByDate(tasks);
    case SortType.urgency:
      return sortByUrgencyHighFirst(tasks);
    default:
      return tasks;
  }
}

List<Task> sortByDate(List<Task> tasks) {
  tasks.sort((a, b) {
    if (a.date == null && b.date == null) return 0;
    if (a.date == null) return 1;
    if (b.date == null) return -1;
    return a.date!.compareTo(b.date!);
  });
  return tasks;
}

List<Task> sortByUrgencyHighFirst(List<Task> tasks) {
  tasks.sort((a, b) {
    if (a.urgencyLevel == TaskPriority.high &&
        b.urgencyLevel != TaskPriority.high) {
      return -1;
    } else if (a.urgencyLevel != TaskPriority.high &&
        b.urgencyLevel == TaskPriority.high) {
      return 1;
    } else {
      return 0;
    }
  });
  return tasks;
}
