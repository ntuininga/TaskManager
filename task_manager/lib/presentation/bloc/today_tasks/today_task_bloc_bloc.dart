import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'today_task_bloc_event.dart';
part 'today_task_bloc_state.dart';

class TodayTaskBlocBloc extends Bloc<TodayTaskBlocEvent, TodayTaskBlocState> {
  TodayTaskBlocBloc() : super(TodayTaskBlocInitial()) {
    on<TodayTaskBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
