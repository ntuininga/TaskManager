part of 'recurring_details_bloc.dart';

sealed class RecurringDetailsEvent extends Equatable {
  const RecurringDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchRecurringTaskDetails extends RecurringDetailsEvent {
  final int taskId;

  FetchRecurringTaskDetails({required this.taskId});

  @override
  List<Object> get props => [taskId];
}
