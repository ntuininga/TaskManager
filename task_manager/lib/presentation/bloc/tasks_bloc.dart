import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;

  TasksBloc({required this.getTaskUseCase}) : super(LoadingGetTasksState()) {
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
  }

  _onGettingTasksEvent(OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksState());
    }

    final result = await getTaskUseCase.call();

    emitter(SuccessGetTasksState(result));
  }
}
