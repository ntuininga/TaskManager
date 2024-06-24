import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/add_task.dart';
import 'package:task_manager/domain/usecases/delete_task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';
import 'package:task_manager/domain/usecases/update_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TasksBloc(
      {required this.getTaskUseCase,
      required this.addTaskUseCase,
      required this.updateTaskUseCase,
      required this.deleteTaskUseCase})
      : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<CompleteTask>(_onCompleteTask);
  }

  Future<void> _refreshTasks(Emitter<TasksState> emitter) async {
    try {
      final result = await getTaskUseCase.call();

      final uncompleteTasks = result.where((task) => !task.isDone).toList();

      final todaysTasks = uncompleteTasks.where((task) {
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
            result, uncompleteTasks, uncompleteTasks, todaysTasks));
      } else {
        emitter(NoTasksState());
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }

    print("Getting Tasks with Bloc");
    await _refreshTasks(emitter);
  }

  Future<void> _onFilterTasksEvent(
      FilterTasks event, Emitter<TasksState> emitter) async {
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
        filteredTasks =
            currentState.uncompleteTasks.where((task) => task.date == null).toList();
      } else {
        filteredTasks = [];
      }

      emitter(SuccessGetTasksState(
          currentState.allTasks,
          currentState.uncompleteTasks,
          filteredTasks,
          currentState.dueTodayTasks));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState ||
          currentState is NoTasksState) {
        print("Success State");
        emitter(LoadingGetTasksState()); // Emit loading state while adding task

        await addTaskUseCase.call(event.taskToAdd);

        await _refreshTasks(emitter); // Refresh the task lists
      } else if (currentState is LoadingGetTasksState) {
        print("Still loading");
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState()); // Emit loading state while adding task

        await deleteTaskUseCase.call(event.id);

        await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState) {
        emitter(
            LoadingGetTasksState()); // Emit loading state while updating task

        await updateTaskUseCase.call(event.taskToUpdate);

        await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
      CompleteTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState) {
        // emitter(
        //     LoadingGetTasksState()); // Emit loading state while updating task

        await updateTaskUseCase.call(event.taskToComplete);

        // await _refreshTasks(emitter); // Refresh the task lists
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }
}
