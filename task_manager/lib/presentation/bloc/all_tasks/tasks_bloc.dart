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
        return task.date == today.year && 
                task.date == today.month &&
                task.date == today.day;
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
}
