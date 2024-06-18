import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/add_task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';
import 'package:task_manager/domain/usecases/update_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;

  TasksBloc({
    required this.getTaskUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
  }) : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }

    try {
      final result = await getTaskUseCase.call();

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
        emitter(SuccessGetTasksState(result, result, todaysTasks));
      } else {
        emitter(NoTasksState());
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onFilterTasksEvent(
      FilterTasks event, Emitter<TasksState> emitter) async {
    final currentState = state;

    if (currentState is SuccessGetTasksState) {
      List<Task> filteredTasks;

      if (event.filter == FilterType.all) {
        filteredTasks = currentState.allTasks;
      } else if (event.filter == FilterType.date) {
        filteredTasks = List.from(currentState.allTasks)
          ..sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return a.date!.compareTo(b.date!);
          });
      } else if (event.filter == FilterType.completed) {
        filteredTasks = currentState.allTasks.where((task) {
          return task.isDone == true;
        }).toList();
      } else {
        filteredTasks = [];
      }

      emitter(SuccessGetTasksState(
          currentState.allTasks, filteredTasks, currentState.dueTodayTasks));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState()); // Emit loading state while adding task

        final addedTask = await addTaskUseCase.call(event.taskToAdd);

        // Update the state with the newly added task
        final List<Task> updatedAllTasks = List.from(currentState.allTasks)
          ..add(addedTask);
        final List<Task> updatedFilteredTasks =
            List.from(currentState.filteredTasks)..add(addedTask);
        final today = DateTime.now();
        final isDueToday = addedTask.date != null &&
            addedTask.date!.year == today.year &&
            addedTask.date!.month == today.month &&
            addedTask.date!.day == today.day;

        var updatedDueTodayTasks = currentState.dueTodayTasks;
        if (isDueToday) {
          updatedDueTodayTasks = List.from(currentState.dueTodayTasks)
            ..add(addedTask);
        }

        emitter(SuccessGetTasksState(
            updatedAllTasks, updatedFilteredTasks, updatedDueTodayTasks));
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emitter) async {
    final currentState = state;

    try {
      if (currentState is SuccessGetTasksState) {
        emitter(LoadingGetTasksState()); // Emit loading state while adding task
        
        await updateTaskUseCase.call(event.taskToUpdate);
        
        final result = await getTaskUseCase.call();

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
          emitter(SuccessGetTasksState(result, result, todaysTasks));
        } else {
          emitter(NoTasksState());
        }
      }
    } catch (e) {
      emitter(ErrorState(e.toString()));
    }
  }
}
