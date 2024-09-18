import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final DeleteAllTasksUseCase deleteAllTasksUseCase;

  List<Task> displayedTasks = [];
  List<Task> filteredTasks = [];
  Filter? currentFilter;

  TasksBloc(
      {required this.getTaskUseCase,
      required this.addTaskUseCase,
      required this.updateTaskUseCase,
      required this.deleteTaskUseCase,
      required this.deleteAllTasksUseCase})
      : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<DeleteAllTasks>(_onDeleteAllTasks);
    on<CompleteTask>(_onCompleteTask);
  }

  Future<void> _refreshTasks(Emitter<TasksState> emitter) async {
    try {
      final result = await getTaskUseCase.call();
      displayedTasks = sortTasksByPriorityAndDate(result);

      final uncompleteTasks =
          displayedTasks.where((task) => !task.isDone).toList();
      final todaysTasks = _getTodaysTasks(displayedTasks);

      emitter(SuccessGetTasksState(
        List.from(displayedTasks),
        List.from(uncompleteTasks),
        List.from(uncompleteTasks),
        List.from(todaysTasks),
        currentFilter,
      ));
    } catch (e) {
      print('Error in _refreshTasks: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    try {
      if (event.withLoading) {
        emitter(LoadingGetTasksState());
      }
      await _refreshTasks(emitter);
    } catch (e) {
      print('Error in _onGettingTasksEvent: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onFilterTasksEvent(
      FilterTasks event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;
      if (currentState is SuccessGetTasksState) {
        currentFilter = Filter(event.filter, event.category);
        filteredTasks = _applyFilter(
            event, currentState.uncompleteTasks, currentState.allTasks);

        emitter(SuccessGetTasksState(
          List.from(currentState.allTasks),
          List.from(currentState.uncompleteTasks),
          List.from(filteredTasks),
          List.from(currentState.dueTodayTasks),
          currentFilter,
        ));
      }
    } catch (e) {
      print('Error in _onFilterTasksEvent: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
    try {
      Task newTask = await addTaskUseCase.call(event.taskToAdd.copyWith(
          urgencyLevel: event.taskToAdd.urgencyLevel ?? TaskPriority.none));

      // If reminder fields are set, schedule the notification
      if (newTask.reminderDate != null && newTask.reminderTime != null) {
        final updatedTask =
            newTask.copyWith(reminder: true); // Update task with reminder
        scheduleNotificationByDateAndTime(
            updatedTask, newTask.reminderDate!, newTask.reminderTime!);
        newTask =
            updatedTask; // Ensure the new task is updated with the reminder flag
      }

      displayedTasks.insert(0, newTask);

      // Apply the current filter to check if the new task should be displayed
      if (_taskMatchesCurrentFilter(newTask)) {
        filteredTasks.insert(0, newTask);
      }

      emitter(SuccessGetTasksState(
        List.from(displayedTasks),
        List.from(displayedTasks.where((task) => !task.isDone).toList()),
        List.from(filteredTasks),
        List.from(_getTodaysTasks(displayedTasks)),
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event, Emitter<TasksState> emitter) async {
    try {
      Task updatedTask = event.taskToUpdate;

      // Check if the task's completion state is changing
      bool isCompletionStateChanging =
          (updatedTask.isDone != event.taskToUpdate.isDone);

      // If the task is being marked as done, add a completed date
      if (isCompletionStateChanging && updatedTask.isDone) {
        updatedTask = updatedTask.copyWith(completedDate: DateTime.now());
      }

      // If the task is being marked as uncompleted, remove the completed date
      if (isCompletionStateChanging && !updatedTask.isDone) {
        updatedTask = updatedTask.copyWith(completedDate: null);
      }

      // Update the task in the repository
      final taskFromRepo = await updateTaskUseCase.call(updatedTask);

      // Find the task in the displayedTasks and remove it if completion state is changing
      if (isCompletionStateChanging) {
        displayedTasks.removeWhere((task) => task.id == taskFromRepo.id);
        filteredTasks.removeWhere((task) => task.id == taskFromRepo.id);
      } else {
        final index =
            displayedTasks.indexWhere((task) => task.id == taskFromRepo.id);
        if (index != -1) {
          displayedTasks[index] = taskFromRepo;
        }
      }

      // Update the filtered tasks based on the current filter and remove if necessary
      final filteredIndex =
          filteredTasks.indexWhere((task) => task.id == taskFromRepo.id);
      if (_taskMatchesCurrentFilter(taskFromRepo)) {
        if (filteredIndex != -1) {
          filteredTasks[filteredIndex] = taskFromRepo;
        } else {
          filteredTasks.insert(0, taskFromRepo);
        }
      } else if (filteredIndex != -1) {
        filteredTasks.removeAt(filteredIndex);
      }

      // Emit the updated state
      emitter(SuccessGetTasksState(
        List.from(displayedTasks), // Ensure we send a copy of the list
        displayedTasks
            .where((task) => !task.isDone)
            .toList(), // Uncompleted tasks
        List.from(filteredTasks), // Ensure we send a copy of the list
        _getTodaysTasks(displayedTasks), // Today's tasks
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event, Emitter<TasksState> emitter) async {
    try {
      await deleteTaskUseCase.call(event.id);
      await flutterLocalNotificationsPlugin.cancel(event.id);

      displayedTasks.removeWhere((task) => task.id == event.id);
      filteredTasks.removeWhere((task) => task.id == event.id);

      emitter(SuccessGetTasksState(
        List.from(displayedTasks),
        List.from(displayedTasks.where((task) => !task.isDone).toList()),
        List.from(filteredTasks),
        List.from(_getTodaysTasks(displayedTasks)),
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emitter) async {
    try {
      await deleteAllTasksUseCase.call();
      await flutterLocalNotificationsPlugin.cancelAll();

      displayedTasks.clear();
      filteredTasks.clear();

      emitter(SuccessGetTasksState(
        List.from(displayedTasks),
        List.from(displayedTasks.where((task) => !task.isDone).toList()),
        List.from(filteredTasks),
        List.from(_getTodaysTasks(displayedTasks)),
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
      CompleteTask event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      Task taskWithCompletedDate = event.taskToComplete;

      if (currentState is SuccessGetTasksState) {
        // Mark the task as done and add a completed date if necessary
        if (taskWithCompletedDate.isDone) {
          taskWithCompletedDate =
              taskWithCompletedDate.copyWith(completedDate: DateTime.now());
          await updateTaskUseCase.call(taskWithCompletedDate);
        }

        // Find the task in the displayedTasks list and update it
        final index = displayedTasks
            .indexWhere((task) => task.id == taskWithCompletedDate.id);
        if (index != -1) {
          displayedTasks[index] = taskWithCompletedDate;

          // Remove from displayedTasks if it no longer matches the current filter
          if (!_taskMatchesCurrentFilter(displayedTasks[index])) {
            displayedTasks.removeAt(index);
          }
        }

        // Update filteredTasks based on whether it matches the current filter
        final filteredIndex = filteredTasks
            .indexWhere((task) => task.id == taskWithCompletedDate.id);

        if (_taskMatchesCurrentFilter(taskWithCompletedDate)) {
          if (filteredIndex != -1) {
            filteredTasks[filteredIndex] = taskWithCompletedDate;
          } else {
            filteredTasks.insert(0, taskWithCompletedDate);
          }
        } else if (filteredIndex != -1) {
          // Remove from filteredTasks if it doesn't match the filter
          filteredTasks.removeAt(filteredIndex);
        }

        // Emit the updated state with the modified task and no movement of other tasks
        emitter(SuccessGetTasksState(
          List.from(displayedTasks), // Ensure we send a copy of the list
          displayedTasks
              .where((task) => !task.isDone)
              .toList(), // Uncompleted tasks
          List.from(filteredTasks), // Ensure we send a copy of the list
          _getTodaysTasks(displayedTasks), // Today's tasks
          currentFilter,
        ));
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  List<Task> sortTasksByDate(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks;
  }

  List<Task> sortTasksByPriorityAndDate(List<Task> tasks) {
    tasks.sort((a, b) {
      int priorityComparison = _priorityValue(a.urgencyLevel)
          .compareTo(_priorityValue(b.urgencyLevel));
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks;
  }

  List<Task> _applyFilter(
      FilterTasks event, List<Task> uncompleteTasks, List<Task> allTasks) {
    List<Task> filteredTasks = uncompleteTasks;

    switch (event.filter) {
      case FilterType.all:
        // No filter applied, show all tasks
        break;

      case FilterType.uncomplete:
        filteredTasks = filteredTasks.where((task) => !task.isDone).toList();
        break;

      case FilterType.completed:
        filteredTasks = allTasks.where((task) => task.isDone).toList();
        break;

      case FilterType.pending:
        filteredTasks = filteredTasks
            .where((task) =>
                !task.isDone &&
                task.date != null &&
                task.date!.isAfter(DateTime.now()))
            .toList();
        break;

      case FilterType.urgency:
        filteredTasks = filteredTasks
            .where((task) => task.urgencyLevel == TaskPriority.high)
            .toList();
        break;

      case FilterType.dueToday:
        filteredTasks = filteredTasks.where((task) {
          if (task.date != null) {
            final today = DateTime.now();
            return task.date!.year == today.year &&
                task.date!.month == today.month &&
                task.date!.day == today.day;
          }
          return false;
        }).toList();
        break;

      case FilterType.date:
        filteredTasks.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;

      case FilterType.category:
        if (event.category != null) {
          filteredTasks = filteredTasks
              .where((task) => task.taskCategory!.id == event.category!.id)
              .toList();
        }
        break;

      case FilterType.nodate:
        filteredTasks =
            filteredTasks.where((task) => task.date == null).toList();
        break;

      case FilterType.overdue:
        filteredTasks = filteredTasks.where((task) {
          if (task.date != null) {
            return task.date!.isBefore(DateTime.now()) && !task.isDone;
          }
          return false;
        }).toList();
        break;
    }

    return filteredTasks;
  }

  bool _taskMatchesCurrentFilter(Task task) {
    // if (currentFilter?.filterType == FilterType.completed) {
    //   return task.isDone;
    // }
    // if (currentFilter?.filterType == FilterType.uncomplete) {
    //   return !task.isDone;
    // }
    if (currentFilter?.filterType == FilterType.category) {
      if (task.taskCategory?.id != null &&
          currentFilter?.filteredCategory?.id != null) {
        return task.taskCategory!.id == currentFilter?.filteredCategory!.id;
      }
    }
    return true; // If no filter is applied, include the task
  }

  List<Task> _getTodaysTasks(List<Task> tasks) {
    DateTime today = DateTime.now();
    return tasks
        .where((task) =>
            task.date != null &&
            task.date!.year == today.year &&
            task.date!.month == today.month &&
            task.date!.day == today.day)
        .toList();
  }

  int _priorityValue(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.none:
        return 1;
      default:
        return 3;
    }
  }
}
