part of 'today_task_bloc_bloc.dart';

sealed class TodayTaskBlocState extends Equatable {
  const TodayTaskBlocState();
  
  @override
  List<Object> get props => [];
}

final class TodayTaskBlocInitial extends TodayTaskBlocState {}

class LoadingGetTasksDueTodayState extends TodayTaskBlocState {}

class SuccessGetTasksDueTodayState extends TodayTaskBlocState {
  final List<Task> tasks;

  SuccessGetTasksDueTodayState(this.tasks);
}

class NoTasksDueTodayState extends TodayTaskBlocState {}
