part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class OnGettingTasksEvent extends TasksEvent {
  final bool withLoading;

  const OnGettingTasksEvent({required this.withLoading});
}

class SortTasks extends TasksEvent {
  final SortType sortType;

  const SortTasks({required this.sortType});
}

class FilterTasks extends TasksEvent {
  final FilterType filter;
  final TaskCategory? category;

  const FilterTasks({required this.filter, this.category});
}

class AddTask extends TasksEvent {
  final Task taskToAdd;

  const AddTask({required this.taskToAdd});
}

class DeleteTask extends TasksEvent {
  final int taskId;
  final Task? task;

  const DeleteTask({required this.taskId, this.task});
}

class DeleteAllTasks extends TasksEvent {}

class UpdateTask extends TasksEvent {
  final Task taskToUpdate;

  const UpdateTask({required this.taskToUpdate});
}

class BulkUpdateTasks extends TasksEvent {
  final List<int> taskIds;
  final TaskCategory? newCategory;
  final bool? markComplete;

  const BulkUpdateTasks({
    required this.taskIds,
    this.newCategory,
    this.markComplete,
  });

  @override
  List<Object?> get props => [taskIds, newCategory, markComplete];
}

class ToggleTaskCompletion extends TasksEvent {
  final int taskId;
  const ToggleTaskCompletion(this.taskId);
}

class CompleteTask extends TasksEvent {
  final Task taskToComplete;

  const CompleteTask({required this.taskToComplete});
}

class CompleteRecurringInstance extends TasksEvent {
  final Task instanceToComplete;

  const CompleteRecurringInstance({required this.instanceToComplete});
}

class RefreshTasksEvent extends TasksEvent {}

class CategoryChangeEvent extends TasksEvent {
  final TaskCategory? category;
  final int? categoryId;
  final VoidCallback? onComplete;

  const CategoryChangeEvent(this.category, this.categoryId, {this.onComplete});
}

class CallRecurringDetailsEvent extends TasksEvent {
  final int taskId;

  const CallRecurringDetailsEvent(this.taskId);
}

enum SortType { none, date, urgency }

enum FilterType {
  all,
  uncomplete,
  completed,
  urgency,
  dueToday,
  category,
  nodate,
  overdue,
  recurring
}

extension FilterTypeExtension on FilterType {
  String get displayName {
    switch (this) {
      case FilterType.all:
        return 'All';
      case FilterType.uncomplete:
        return 'Uncomplete';
      case FilterType.completed:
        return 'Completed';
      case FilterType.urgency:
        return 'Urgency';
      case FilterType.dueToday:
        return 'Due Today';
      case FilterType.category:
        return 'Category';
      case FilterType.nodate:
        return 'No Date';
      case FilterType.overdue:
        return 'Overdue';
      case FilterType.recurring:
        return 'Recurring';
    }
  }
}
