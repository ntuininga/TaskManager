part of 'tasks_bloc.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

final class TasksInitial extends TasksState {}

class LoadingGetTasksState extends TasksState {}

class SuccessGetTasksState extends TasksState {
  final List<Task> allTasks;
  final List<Task> uncompleteTasks;
  final List<Task> filteredTasks;
  final List<Task> dueTodayTasks;
  // final List<TaskCategory> taskCategories;

  const SuccessGetTasksState(this.allTasks, this.uncompleteTasks, this.filteredTasks,
      this.dueTodayTasks);

  @override
  List<Object> get props =>
      [allTasks, uncompleteTasks, filteredTasks, dueTodayTasks];
}

class NoTasksState extends TasksState {}

class ErrorState extends TasksState {
  final String errorMsg;

  const ErrorState(this.errorMsg);
}
