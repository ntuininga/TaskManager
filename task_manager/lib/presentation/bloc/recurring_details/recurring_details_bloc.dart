import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/usecases/add_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/clear_all_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/get_recurrence_details_usecase.dart';
import 'package:task_manager/domain/usecases/recurring_task_details/add_completed_date_usecase.dart';
import 'package:task_manager/domain/usecases/recurring_task_details/remove_scheduled_date_usecase.dart';
import 'package:task_manager/domain/usecases/update_existing_recurring_dates_usecase.dart';

part 'recurring_details_event.dart';
part 'recurring_details_state.dart';

class RecurringDetailsBloc
    extends Bloc<RecurringDetailsEvent, RecurringDetailsState> {
  final GetRecurrenceDetailsUsecase getRecurrenceDetailsUsecase;
  final AddScheduledDatesUseCase addScheduledDatesUseCase;
  final ClearScheduledDatesUseCase clearScheduledDatesUseCase;
  final UpdateScheduledDatesUseCase updateScheduledDatesUseCase;
  final AddCompletedDateUseCase addCompletedDateUseCase;
  final RemoveScheduledDateUseCase removeScheduledDateUseCase;

  RecurringDetailsBloc(
      {required this.getRecurrenceDetailsUsecase,
      required this.addScheduledDatesUseCase,
      required this.clearScheduledDatesUseCase,
      required this.updateScheduledDatesUseCase,
      required this.addCompletedDateUseCase,
      required this.removeScheduledDateUseCase})
      : super(RecurringDetailsInitial()) {
    on<FetchRecurringTaskDetails>(_onGetRecurrenceDetails);
    on<ScheduleRecurringTaskDates>(_onScheduleRecurringTaskDates);
    on<ClearRecurringTaskDates>(_onClearRecurringTaskDates);
    on<UpdateRecurringTaskDates>(_onUpdateRecurringDates);
    on<CompleteRecurringTask>(_onCompleteRecurringTask);
  }

  Future<void> _onGetRecurrenceDetails(FetchRecurringTaskDetails event,
      Emitter<RecurringDetailsState> emit) async {
    emit(RecurringTaskDetailsLoading());
    try {
      final details = await getRecurrenceDetailsUsecase(event.taskId);
      emit(RecurringTaskDetailsLoaded(details: details));
    } catch (e, stackTrace) {
      debugPrint("Error: $e\nStackTrace: $stackTrace");
      emit(RecurringTaskDetailsError(message: e.toString()));
    }
  }

  Future<void> _onClearRecurringTaskDates(ClearRecurringTaskDates event,
      Emitter<RecurringDetailsState> emit) async {
    try {
      await clearScheduledDatesUseCase(event.taskId);
    } catch (e, stackTrace) {
      debugPrint("Error: $e\nStackTrace: $stackTrace");
      emit(RecurringTaskScheduleError(message: e.toString()));
    }
  }

  Future<void> _onCompleteRecurringTask(
      CompleteRecurringTask event, Emitter<RecurringDetailsState> emit) async {
    try {
      // Get the task details
      final task = event.task;
      final details = await getRecurrenceDetailsUsecase(task.id!);

      // Get the list of scheduled dates for this task
      List<DateTime> scheduledDates = List.from(details.scheduledDates ?? []);
      List<DateTime> nextScheduledDates = [];

      // Ensure there are enough future dates
      if (scheduledDates.isNotEmpty && scheduledDates.length < 7) {
        int count = 7 - scheduledDates.length;
        nextScheduledDates = _calculateNextRecurringDates(
          startDate: scheduledDates.last,
          frequency: task.recurrenceRuleset!.frequency!,
          count: count,
        );
      }

      // Determine the completed date
      DateTime completedDate = event.completedDate ??
          (scheduledDates.isNotEmpty
              ? scheduledDates.reduce((a, b) => 
                  a.isBefore(b) && b.isBefore(DateTime.now()) ? b : a)
              : DateTime.now());

      // Remove completed date from scheduled dates
      scheduledDates.remove(completedDate);

      // Add the completed date to the database
      await addCompletedDateUseCase(task.id!, completedDate);

      // Create updated scheduled dates list
      final updatedScheduledDates = [...scheduledDates, ...nextScheduledDates];

      // Update the scheduled dates in the database
      await updateScheduledDatesUseCase(
          taskId: task.id!, newScheduledDates: updatedScheduledDates);

      // Schedule notifications for the new recurring task dates
      await scheduleNotificationsForRecurringTask(task, nextScheduledDates);

      // Emit success state
      emit(RecurringTaskScheduled(nextScheduledDates: nextScheduledDates));
    } catch (e, stackTrace) {
      debugPrint("Error: $e\nStackTrace: $stackTrace");
      emit(RecurringTaskScheduleError(message: e.toString()));
    }
  }


  Future<void> _onUpdateRecurringDates(UpdateRecurringTaskDates event,
      Emitter<RecurringDetailsState> emit) async {
    try {
      List<DateTime>? newScheduledDates = event.newScheduledDates;

      // Check if the newScheduledDates are valid, else calculate them.
      if (newScheduledDates == null || newScheduledDates.isEmpty) {
        if (event.task.recurrenceRuleset?.frequency == null) {
          emit(const RecurringTaskScheduleError(
              message: 'Recurrence frequency is missing.'));
          return;
        }
        newScheduledDates = _calculateNextRecurringDates(
            startDate: event.task.date!,
            frequency: event.task.recurrenceRuleset!.frequency!);
      }

      // Ensure no null task and notify
      if (event.task.id == null) {
        emit(const RecurringTaskScheduleError(message: 'Task ID is null.'));
        return;
      }

      await cancelAllNotificationsForTask(event.task.id!);
      await scheduleNotificationsForRecurringTask(
          event.task, newScheduledDates);

      await updateScheduledDatesUseCase(
          taskId: event.task.id!, newScheduledDates: newScheduledDates);
    } catch (e, stackTrace) {
      debugPrint("Error: $e\nStackTrace: $stackTrace");
      emit(RecurringTaskScheduleError(message: e.toString()));
    }
  }

  Future<void> _onScheduleRecurringTaskDates(ScheduleRecurringTaskDates event,
      Emitter<RecurringDetailsState> emit) async {
    try {
      // Check if the frequency is provided and valid
      emit(const RecurringTaskScheduleError(message: 'Frequency is missing.'));

      final nextScheduledDates = _calculateNextRecurringDates(
          startDate: event.startDate, frequency: event.frequency);

      if (nextScheduledDates.isEmpty) {
        emit(const RecurringTaskScheduleError(
            message: 'No recurring dates calculated.'));
        return;
      }

      // Add scheduled dates and schedule notifications
      await addScheduledDatesUseCase(event.taskId, nextScheduledDates);

      await scheduleNotificationsForRecurringTask(
          event.task, nextScheduledDates);

      emit(RecurringTaskScheduled(nextScheduledDates: nextScheduledDates));
    } catch (e, stackTrace) {
      debugPrint("Error: $e\nStackTrace: $stackTrace");
      emit(RecurringTaskScheduleError(message: e.toString()));
    }
  }

  List<DateTime> _calculateNextRecurringDates({
    required DateTime startDate,
    required Frequency frequency,
    int count = 7, // Default value set to 7
  }) {
    List<DateTime> nextDates = [];
    DateTime nextDate = startDate;

    for (int i = 0; i < count; i++) {
      // Use count instead of hardcoded 7
      nextDates.add(nextDate); // Store before modifying

      switch (frequency) {
        case Frequency.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case Frequency.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case Frequency.monthly:
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 1,
            nextDate.day > DateTime(nextDate.year, nextDate.month + 1, 0).day
                ? DateTime(nextDate.year, nextDate.month + 1, 0).day
                : nextDate.day,
          );
          break;
        case Frequency.yearly:
          nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
          break;
      }
    }

    return nextDates;
  }
}
