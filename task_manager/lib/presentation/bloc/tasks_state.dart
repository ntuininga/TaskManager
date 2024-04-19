part of 'tasks_bloc.dart';

sealed class TasksState extends Equatable {
  const TasksState();
  
  @override
  List<Object> get props => [];
}

final class TasksInitial extends TasksState {}

class LoadingGetTasksState extends TasksState {}

class SuccessGetTasksState extends TasksState {
  final List<Task> tasks;

  SuccessGetTasksState(this.tasks);
}
