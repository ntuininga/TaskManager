part of 'recurring_instance_bloc.dart';

sealed class RecurringInstanceState extends Equatable {
  const RecurringInstanceState();
  
  @override
  List<Object> get props => [];
}



final class RecurringInstanceInitial extends RecurringInstanceState {}

class ErrorState extends RecurringInstanceState {
  final String errorMsg;

  const ErrorState(this.errorMsg);
}
