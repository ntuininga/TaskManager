import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/usecases/get_recurrence_details_usecase.dart';

part 'recurring_details_event.dart';
part 'recurring_details_state.dart';

class RecurringDetailsBloc
    extends Bloc<RecurringDetailsEvent, RecurringDetailsState> {
  final GetRecurrenceDetailsUsecase getRecurrenceDetailsUsecase;
  RecurringDetailsBloc({required this.getRecurrenceDetailsUsecase})
      : super(RecurringDetailsInitial()) {
    on<FetchRecurringTaskDetails>(_onGetRecurrenceDetails);
  }

  Future<void> _onGetRecurrenceDetails(FetchRecurringTaskDetails event,
      Emitter<RecurringDetailsState> emit) async {
    emit(RecurringTaskDetailsLoading());
    try {
      final details = await getRecurrenceDetailsUsecase(event.taskId);
      emit(RecurringTaskDetailsLoaded(details: details));
    } catch (e) {
      emit(RecurringTaskDetailsError(message: e.toString()));
    }
  }
}
