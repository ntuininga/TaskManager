import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
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
      final todaysTasks = displayedTasks.where((task) {
        if (task.date != null) {
          final today = DateTime.now();
          return task.date!.year == today.year &&
              task.date!.month == today.month &&
              task.date!.day == today.day;
        } else {
          return false;
        }
      }).toList();

      emitter(SuccessGetTasksState(
        displayedTasks,
        uncompleteTasks,
        uncompleteTasks,
        todaysTasks,
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
        List<Task> filteredTasks;

        if (event.filter == FilterType.all) {
          filteredTasks = currentState.uncompleteTasks;
        } else if (event.filter == FilterType.date) {
          filteredTasks = sortTasksByDate(currentState.uncompleteTasks);
        } else if (event.filter == FilterType.urgency) {
          filteredTasks = currentState.uncompleteTasks
              .where((task) => task.urgencyLevel == TaskPriority.high)
              .toList();
        } else if (event.filter == FilterType.completed) {
          filteredTasks =
              currentState.allTasks.where((task) => task.isDone).toList();
        } else if (event.filter == FilterType.uncomplete) {
          filteredTasks =
              currentState.allTasks.where((task) => !task.isDone).toList();
          filteredTasks = sortTasksByPriorityAndDate(filteredTasks);
        } else if (event.filter == FilterType.nodate) {
          filteredTasks = currentState.uncompleteTasks
              .where((task) => task.date == null)
              .toList();
        } else if (event.filter == FilterType.category) {
          if (event.categoryId != null) {
            filteredTasks = currentState.uncompleteTasks
                .where((task) => task.taskCategoryId == event.categoryId)
                .toList();
          } else {
            filteredTasks = currentState.uncompleteTasks
                .where((task) => task.taskCategoryId == null)
                .toList();
          }

          filteredTasks = sortTasksByPriorityAndDate(filteredTasks);
        } else if (event.filter == FilterType.overdue) {
          filteredTasks = currentState.uncompleteTasks.where((task) {
            if (task.date != null) {
              final DateTime now = DateTime.now();
              return task.date!.year < now.year ||
                  (task.date!.year == now.year &&
                      task.date!.month < now.month) ||
                  (task.date!.year == now.year &&
                      task.date!.month == now.month &&
                      task.date!.day < now.day);
            }
            return false;
          }).toList();
          filteredTasks = sortTasksByDate(filteredTasks);
        } else {
          filteredTasks = [];
        }

        displayedTasks = filteredTasks;

        emitter(SuccessGetTasksState(
          currentState.allTasks,
          currentState.uncompleteTasks,
          filteredTasks,
          currentState.dueTodayTasks,
        ));
      }
    } catch (e) {
      print('Error in _onFilterTasksEvent: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
    try {

      final newTask = await addTaskUseCase.call(event.taskToAdd);
      
      displayedTasks = [newTask.copyWith(taskCategoryId: 0), ...displayedTasks]; // Update displayedTasks

      emitter(SuccessGetTasksState(
        displayedTasks,
        displayedTasks.where((task) => !task.isDone).toList(),
        displayedTasks.where((task) => !task.isDone).toList(),
        displayedTasks.where((task) {
          if (task.date != null) {
            final today = DateTime.now();
            return task.date!.year == today.year &&
                task.date!.month == today.month &&
                task.date!.day == today.day;
          } else {
            return false;
          }
        }).toList(),
      ));
    } catch (e) {
      print('Error in _onAddTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState()); // Emit loading state while adding task

        await deleteTaskUseCase.call(event.id);

        await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      print('Error in _onDeleteTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState()); // Emit loading state while adding task

        await deleteAllTasksUseCase.call();

        await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      print('Error in _onDeleteTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        emitter(
            LoadingGetTasksState()); // Emit loading state while updating task

        await updateTaskUseCase.call(event.taskToUpdate);

        await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      print('Error in _onUpdateTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
      CompleteTask event, Emitter<TasksState> emitter) async {
    try {
      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        Task taskWithCompletedDate =
            event.taskToComplete.copyWith(completedDate: DateTime.now());
        await updateTaskUseCase.call(taskWithCompletedDate);

        // Reorder tasks after completion to keep new tasks at the top
        final updatedTaskList = [
          ...currentState.allTasks
              .where((task) => task.id != taskWithCompletedDate.id),
          taskWithCompletedDate
        ];

        emitter(SuccessGetTasksState(
          updatedTaskList,
          updatedTaskList.where((task) => !task.isDone).toList(),
          updatedTaskList.where((task) => !task.isDone).toList(),
          updatedTaskList.where((task) {
            if (task.date != null) {
              final today = DateTime.now();
              return task.date!.year == today.year &&
                  task.date!.month == today.month &&
                  task.date!.day == today.day;
            } else {
              return false;
            }
          }).toList(),
        ));
      }
    } catch (e) {
      print('Error in _onCompleteTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }

  List<Task> sortTasksByDate(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.date == null && b.date == null) return 0; // Both tasks have no date
      if (a.date == null) return 1; // a has no date, so it's placed after b
      if (b.date == null) return -1; // b has no date, so it's placed after a
      return a.date!
          .compareTo(b.date!); // Compare dates if both tasks have dates
    });
    return tasks;
  }

  List<Task> sortTasksByPriority(List<Task> tasks) {
    tasks.sort((a, b) {
      int priorityComparison = _priorityValue(a.urgencyLevel)
          .compareTo(_priorityValue(b.urgencyLevel));
      return priorityComparison;
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

  int _priorityValue(TaskPriority? priority) {
    if (priority == null) return 2;
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.none:
        return 1;
    }
  }
}
