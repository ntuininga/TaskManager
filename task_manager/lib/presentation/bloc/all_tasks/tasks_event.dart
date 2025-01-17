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
  final int id;

  const DeleteTask({required this.id});
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

class RefreshTasksEvent extends TasksEvent {}

class CategoryChangeEvent extends TasksEvent {
  final TaskCategory? category;
  final int? categoryId;
  final VoidCallback? onComplete;

  const CategoryChangeEvent(this.category, this.categoryId, {this.onComplete});
}

enum FilterType {
  all,
  uncomplete,
  completed,
  pending,
  urgency,
  dueToday,
  date,
  category,
  nodate,
  overdue
}
