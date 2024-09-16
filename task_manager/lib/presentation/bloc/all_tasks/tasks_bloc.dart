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
      displayedTasks =
          sortTasksByPriorityAndDate(result); // Initialize displayedTasks

      final uncompleteTasks =
          displayedTasks.where((task) => !task.isDone).toList();
      final todaysTasks = _getTodaysTasks(displayedTasks);

      emitter(SuccessGetTasksState(displayedTasks, uncompleteTasks,
          uncompleteTasks, todaysTasks, currentFilter));
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

        filteredTasks = _applyFilter(event, currentState.uncompleteTasks, currentState.allTasks);

        emitter(SuccessGetTasksState(
            currentState.allTasks,
            currentState.uncompleteTasks,
            filteredTasks,
            currentState.dueTodayTasks,
            currentFilter));
      }
    } catch (e) {
      print('Error in _onFilterTasksEvent: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
    try {
      final newTask = await addTaskUseCase.call(event.taskToAdd);

      if (newTask.reminderDate != null && newTask.reminderTime != null) {
        newTask.copyWith(reminder: true);
        scheduleNotificationByDateAndTime(
            newTask, newTask.reminderDate!, newTask.reminderTime!);
      }

      displayedTasks.insert(
          0, newTask); // Add new task to the top of displayedTasks

      // Apply the current filter and check if the new task should be displayed
      if (_taskMatchesCurrentFilter(newTask)) {
        filteredTasks.insert(0, newTask);
      }

      emitter(SuccessGetTasksState(
        displayedTasks,
        displayedTasks.where((task) => !task.isDone).toList(),
        filteredTasks,
        _getTodaysTasks(displayedTasks),
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event, Emitter<TasksState> emitter) async {
    try {
      final updatedTask = await updateTaskUseCase.call(event.taskToUpdate);

      // Update the task in the displayedTasks
      final index =
          displayedTasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        displayedTasks[index] = updatedTask;
      }

      // Apply the current filter and check if the updated task should be displayed
      if (_taskMatchesCurrentFilter(updatedTask)) {
        final filteredIndex =
            filteredTasks.indexWhere((task) => task.id == updatedTask.id);
        if (filteredIndex != -1) {
          filteredTasks[filteredIndex] = updatedTask;
        } else {
          filteredTasks.insert(0, updatedTask);
        }
      } else {
        filteredTasks.removeWhere((task) => task.id == updatedTask.id);
      }

      emitter(SuccessGetTasksState(
        displayedTasks,
        displayedTasks.where((task) => !task.isDone).toList(),
        filteredTasks,
        _getTodaysTasks(displayedTasks),
        currentFilter,
      ));
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState());

        await deleteTaskUseCase.call(event.id);
        await flutterLocalNotificationsPlugin.cancel(event.id);

        displayedTasks.removeWhere((task) => task.id == event.id);
        filteredTasks.removeWhere((task) => task.id == event.id);

        emitter(SuccessGetTasksState(
          displayedTasks,
          displayedTasks.where((task) => !task.isDone).toList(),
          filteredTasks,
          _getTodaysTasks(displayedTasks),
          currentFilter,
        ));
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState());

        await deleteAllTasksUseCase.call();
        await flutterLocalNotificationsPlugin.cancelAll();

        displayedTasks.clear();
        filteredTasks.clear();

        emitter(SuccessGetTasksState(
          displayedTasks,
          displayedTasks.where((task) => !task.isDone).toList(),
          filteredTasks,
          _getTodaysTasks(displayedTasks),
          currentFilter,
        ));
      }
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
        if (event.taskToComplete.isDone) {
          taskWithCompletedDate =
              event.taskToComplete.copyWith(completedDate: DateTime.now());
          await updateTaskUseCase.call(taskWithCompletedDate);
        }

        final updatedTaskList = [
          ...currentState.allTasks
              .where((task) => task.id != taskWithCompletedDate.id),
          taskWithCompletedDate
        ];

        emitter(SuccessGetTasksState(
            updatedTaskList,
            updatedTaskList.where((task) => !task.isDone).toList(),
            updatedTaskList.where((task) => !task.isDone).toList(),
            _getTodaysTasks(updatedTaskList),
            currentFilter));
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


List<Task> _applyFilter(FilterTasks event, List<Task> uncompleteTasks, List<Task> allTasks) {
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
            .where((task) => task.taskCategoryId == event.category!.id)
            .toList();
      }
      break;

    case FilterType.nodate:
      filteredTasks = filteredTasks.where((task) => task.date == null).toList();
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
    if (currentFilter?.activeFilter == FilterType.category) {
      return task.taskCategory == currentFilter?.filteredCategory;
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
