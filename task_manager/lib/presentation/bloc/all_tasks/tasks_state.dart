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
  final List<Task> displayTasks;
  final List<Task> dueTodayTasks;
  final List<Task> urgentTasks;
  final List<Task> uncompleteTasks;
  final List<Task> completeTasks;
  final List<Task> filteredTasks;
  final Filter? activeFilter;
  final int todayCount;
  final int urgentCount;
  final int overdueCount;

  const SuccessGetTasksState(
      {required this.allTasks,
      required this.displayTasks,
      required this.dueTodayTasks,
      required this.urgentTasks,
      required this.uncompleteTasks,
      required this.completeTasks,
      required this.filteredTasks,
      required this.activeFilter,
      required this.todayCount,
      required this.urgentCount,
      required this.overdueCount});

  @override
  List<Object> get props => [
        allTasks,
        dueTodayTasks,
        urgentTasks,
        uncompleteTasks,
        completeTasks,
        filteredTasks
      ];
}

class NoTasksState extends TasksState {}

class ErrorState extends TasksState {
  final String errorMsg;

  const ErrorState(this.errorMsg);
}

class TaskAddedState extends SuccessGetTasksState {
  final Task newTask;

  const TaskAddedState({
    required this.newTask,
    required List<Task> allTasks,
    required List<Task> displayTasks,
    required List<Task> dueTodayTasks,
    required List<Task> urgentTasks,
    required List<Task> uncompleteTasks,
    required List<Task> completeTasks,
    required List<Task> filteredTasks,
    required Filter? activeFilter,
    required int todayCount,
    required int urgentCount,
    required int overdueCount,
  }) : super(
          allTasks: allTasks,
          displayTasks: displayTasks,
          dueTodayTasks: dueTodayTasks,
          urgentTasks: urgentTasks,
          uncompleteTasks: uncompleteTasks,
          completeTasks: completeTasks,
          filteredTasks: filteredTasks,
          activeFilter: activeFilter,
          todayCount: todayCount,
          urgentCount: urgentCount,
          overdueCount: overdueCount,
        );

  @override
  List<Object> get props => super.props..add(newTask);
}
