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
  final List<Task> filteredTasks;
  final List<Task> dueTodayTasks;

  SuccessGetTasksState(
    this.allTasks,
    this.filteredTasks,
    this.dueTodayTasks);

  @override
  List<Object> get props => [allTasks, filteredTasks, dueTodayTasks];
}

class NoTasksState extends TasksState {}

class ErrorState extends TasksState {
  final String errorMsg;

  ErrorState(this.errorMsg);
}


