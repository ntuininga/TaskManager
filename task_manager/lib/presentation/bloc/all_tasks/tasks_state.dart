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
  final Filter activeFilter;
  final List<Task> today;
  final List<Task> urgent;
  final List<Task> overdue;
  final Map<TaskCategory, List<Task>> tasksByCategory;
  final List<TaskCategory> allCategories;

  const SuccessGetTasksState({
    required this.allTasks,
    required this.displayTasks,
    required this.activeFilter,
    required this.today,
    required this.urgent,
    required this.overdue,
    required this.tasksByCategory,
    required this.allCategories
  });

  @override
  List<Object> get props => [
        allTasks,
        displayTasks,
        // dueTodayTasks,
        // urgentTasks,
        // uncompleteTasks,
        // completeTasks,
        activeFilter,
        today,
        urgent,
        overdue,
      ];
}


class NoTasksState extends TasksState {}

class ErrorState extends TasksState {
  final String errorMsg;

  const ErrorState(this.errorMsg);
}

// class TaskAddedState extends SuccessGetTasksState {
//   final Task newTask;

//   const TaskAddedState({
//     required this.newTask,
//     required List<Task> allTasks,
//     required List<Task> displayTasks,
//     required Filter activeFilter,
//     required List<Task> today,
//     required List<Task> urgent,
//     required List<Task> overdue,
//   }) : super(
//           allTasks: allTasks,
//           displayTasks: displayTasks,
//           activeFilter: activeFilter,
//           today: today,
//           urgent: urgent,
//           overdue: overdue,
//         );

//   @override
//   List<Object> get props => super.props..add(newTask);
// }
