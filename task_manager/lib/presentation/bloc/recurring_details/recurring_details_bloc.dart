import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/usecases/add_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/get_recurrence_details_usecase.dart';

part 'recurring_details_event.dart';
part 'recurring_details_state.dart';

class RecurringDetailsBloc
    extends Bloc<RecurringDetailsEvent, RecurringDetailsState> {
  final GetRecurrenceDetailsUsecase getRecurrenceDetailsUsecase;
  final AddScheduledDatesUseCase addScheduledDatesUseCase;
  RecurringDetailsBloc(
      {required this.getRecurrenceDetailsUsecase,
      required this.addScheduledDatesUseCase})
      : super(RecurringDetailsInitial()) {
    on<FetchRecurringTaskDetails>(_onGetRecurrenceDetails);
    on<ScheduleRecurringTaskDates>(_onScheduleRecurringTaskDates);
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

  Future<void> _onScheduleRecurringTaskDates(ScheduleRecurringTaskDates event,
      Emitter<RecurringDetailsState> emit) async {
    try {
      // Fetch recurring task details again (in case the details have changed)
      // final recurringTaskDetails = await getRecurrenceDetailsUsecase(event.taskId);

      // Calculate the next recurring dates
      final nextScheduledDates = _calculateNextRecurringDates(
          startDate: event.startDate, frequency: event.frequency);

      await addScheduledDatesUseCase(event.taskId, nextScheduledDates);
      emit(RecurringTaskScheduled(nextScheduledDates: nextScheduledDates));
    } catch (e) {
      emit(RecurringTaskScheduleError(message: e.toString()));
    }
  }

  // Function to calculate next 7 recurring dates based on frequency
  List<DateTime> _calculateNextRecurringDates({
    required DateTime startDate,
    required Frequency frequency,
  }) {
    List<DateTime> nextDates = [];

    DateTime nextDate = startDate;

    // Calculate the next 7 recurring dates based on frequency
    for (int i = 0; i < 7; i++) {
      switch (frequency) {
        case Frequency.daily:
          nextDate = nextDate.add(Duration(days: 1));
          break;
        case Frequency.weekly:
          nextDate = nextDate.add(Duration(days: 7));
          break;
        case Frequency.monthly:
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          break;
        case Frequency.yearly:
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          break;
        default:
          throw Exception("Unsupported frequency type");
      }

      nextDates.add(nextDate);
    }

    return nextDates;
  }
}
