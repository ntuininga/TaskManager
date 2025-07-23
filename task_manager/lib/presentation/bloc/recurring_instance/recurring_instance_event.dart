part of 'recurring_instance_bloc.dart';

sealed class RecurringInstanceEvent extends Equatable {
  const RecurringInstanceEvent();

  @override
  List<Object> get props => [];
}

class CompleteRecurringInstance extends RecurringInstanceEvent {
  final RecurringInstance instance;

  const CompleteRecurringInstance({required this.instance});
}
