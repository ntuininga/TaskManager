import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';
import 'package:task_manager/domain/usecases/get_tasks_due_today.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final GetTasksDueToday getTasksDueToday;

  TasksBloc({
    required this.getTaskUseCase, 
    required this.getTasksDueToday
  }) : super(LoadingGetTasksState()) {
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<OnGettingTasksDueTodayEvent>(_onGettingTasksDueTodayEvent);
  }

  Future<void> _onGettingTasksEvent(OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }

    final result = await getTaskUseCase.call();

    if (result.isNotEmpty) {
      emitter(SuccessGetTasksState(result));
    } else {
      emitter(NoTasksState());
    }
  }

  Future<void> _onGettingTasksDueTodayEvent(OnGettingTasksDueTodayEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }
    
    try {
      final tasksDueToday = await getTasksDueToday.call();

    if (tasksDueToday.isNotEmpty) {
      emitter(SuccessGetTasksDueTodayState(tasksDueToday));
    } else {
      emitter(NoTasksDueTodayState());
    }
    } catch (e) {
      print(e.toString());
    }
  }
}
