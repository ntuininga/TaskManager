part of 'today_task_bloc_bloc.dart';

sealed class TodayTaskBlocState extends Equatable {
  const TodayTaskBlocState();
  
  @override
  List<Object> get props => [];
}

final class TodayTaskBlocInitial extends TodayTaskBlocState {}
