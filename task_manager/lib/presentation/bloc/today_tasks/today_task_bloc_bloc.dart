import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/get_tasks_due_today.dart';

part 'today_task_bloc_event.dart';
part 'today_task_bloc_state.dart';

class TodayTaskBlocBloc extends Bloc<TodayTaskBlocEvent, TodayTaskBlocState> {
  final GetTasksDueToday getTasksDueTodayUseCase;

  TodayTaskBlocBloc({
    required this.getTasksDueTodayUseCase
  }) : super(TodayTaskBlocInitial()) {
    on<OnGettingTasksDueTodayEvent>(_onGettingTasksDueTodayEvent);
  }

  Future<void> _onGettingTasksDueTodayEvent(OnGettingTasksDueTodayEvent event, Emitter<TodayTaskBlocState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTasksDueTodayState());
    }
    
    try {
      final tasksDueToday = await getTasksDueTodayUseCase.call();

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
