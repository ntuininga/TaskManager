part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

class OnGettingTasksEvent extends TasksEvent {
  final bool withLoading;

  const OnGettingTasksEvent({required this.withLoading});
}

class FilterTasks extends TasksEvent {
  final FilterType filter;
  final int? categoryId;

  const FilterTasks({required this.filter, this.categoryId});
}

class AddTask extends TasksEvent {
  final Task taskToAdd;

  const AddTask({required this.taskToAdd});
}

class DeleteTask extends TasksEvent {
  final int id;

  const DeleteTask({required this.id});
}

class UpdateTask extends TasksEvent {
  final Task taskToUpdate;

  const UpdateTask({required this.taskToUpdate});
}

class CompleteTask extends TasksEvent {
  final Task taskToComplete;

  const CompleteTask({required this.taskToComplete});
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
  nodate
}
