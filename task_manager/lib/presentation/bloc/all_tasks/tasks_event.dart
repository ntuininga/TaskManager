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

class OnGettingTasksDueTodayEvent extends TasksEvent {
  final bool withLoading;

  const OnGettingTasksDueTodayEvent({required this.withLoading});
}