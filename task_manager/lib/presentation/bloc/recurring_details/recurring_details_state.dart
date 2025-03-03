part of 'recurring_details_bloc.dart';

sealed class RecurringDetailsState extends Equatable {
  const RecurringDetailsState();
  
  @override
  List<Object> get props => [];
}

final class RecurringDetailsInitial extends RecurringDetailsState {}

class RecurringTaskDetailsLoading extends RecurringDetailsState {}

class RecurringTaskDetailsLoaded extends RecurringDetailsState {
  final RecurringTaskDetails details;

  RecurringTaskDetailsLoaded({required this.details});

  @override
  List<Object> get props => [details];
}

class RecurringTaskDetailsError extends RecurringDetailsState {
  final String message;

  RecurringTaskDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}