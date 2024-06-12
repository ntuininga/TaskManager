part of 'today_task_bloc_bloc.dart';

sealed class TodayTaskBlocEvent extends Equatable {
  const TodayTaskBlocEvent();

  @override
  List<Object> get props => [];
}

class OnGettingTasksDueTodayEvent extends TodayTaskBlocEvent {
  final bool withLoading;

  const OnGettingTasksDueTodayEvent({required this.withLoading});
}
