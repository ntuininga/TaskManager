import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
      final uncompleteTasks = result.where((task) => !task.isDone).toList();
      final todaysTasks = result.where((task) {
        if (task.date != null) {
          final today = DateTime.now();
          return task.date!.year == today.year &&
              task.date!.month == today.month &&
              task.date!.day == today.day;
        } else {
          return false;
        }
      }).toList();

      if (result.isNotEmpty) {
        emitter(SuccessGetTasksState(
          result,
          uncompleteTasks,
          uncompleteTasks,
          todaysTasks,
        ));
      } else {
        emitter(NoTasksState());
      }
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
      await _refreshTasks(emitter);

      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        List<Task> filteredTasks;

        if (event.filter == FilterType.all) {
          filteredTasks = currentState.allTasks;
        } else if (event.filter == FilterType.date) {
          filteredTasks = List.from(currentState.uncompleteTasks)
            ..sort((a, b) {
              if (a.date == null && b.date == null) return 0;
              if (a.date == null) return 1;
              if (b.date == null) return -1;
              return a.date!.compareTo(b.date!);
            });
        } else if (event.filter == FilterType.completed) {
          filteredTasks =
              currentState.allTasks.where((task) => task.isDone).toList();
        } else if (event.filter == FilterType.uncomplete) {
          filteredTasks =
              currentState.allTasks.where((task) => !task.isDone).toList();
        } else if (event.filter == FilterType.nodate) {
          filteredTasks = currentState.uncompleteTasks
              .where((task) => task.date == null)
              .toList();
        } else if (event.filter == FilterType.category) {
          filteredTasks = currentState.uncompleteTasks
              .where((task) => task.taskCategoryId == event.categoryId)
              .toList();
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
        } else {
          filteredTasks = [];
        }

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
    final currentState = state;

    if (currentState is SuccessGetTasksState || currentState is NoTasksState) {
      emitter(LoadingGetTasksState()); // Emit loading state while adding task

      final newTask = await addTaskUseCase.call(event.taskToAdd);

      // Prepend the new task to the current list of tasks
      final List<Task> updatedTaskList = [newTask, ...currentState is SuccessGetTasksState ? currentState.allTasks : []];

      // Emit the updated state with the new task list
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
      }

      await _refreshTasks(emitter);
    } catch (e) {
      print('Error in _onCompleteTask: $e');
      emitter(ErrorState(e.toString()));
    }
  }
}
