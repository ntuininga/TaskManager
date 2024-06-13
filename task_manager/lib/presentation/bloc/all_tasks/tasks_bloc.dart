import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;

  TasksBloc({
    required this.getTaskUseCase, 
  }) : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
  }

  Future<void> _onGettingTasksEvent(OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }

    final result = await getTaskUseCase.call();

    final todaysTasks = result.where((task){
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

  Future<void> _onFilterTasksEvent(FilterTasks event, Emitter<TasksState> emitter) async {
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
        filteredTasks = currentState.allTasks.where((task){
          return task.isDone == true;
        }).toList();
      } else {
        filteredTasks = [];
      }

      emitter(SuccessGetTasksState(currentState.allTasks, filteredTasks, currentState.dueTodayTasks));
    }
  }
}
