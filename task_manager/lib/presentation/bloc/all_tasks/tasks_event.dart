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

  const FilterTasks({required this.filter});
}

class AddTask extends TasksEvent {
  final Task taskToAdd;

  const AddTask({required this.taskToAdd});
}

class UpdateTask extends TasksEvent {
  final Task taskToUpdate;

  const UpdateTask({required this.taskToUpdate});
}

enum FilterType  {
  all,
  completed,
  pending,
  dueToday,
  date
}