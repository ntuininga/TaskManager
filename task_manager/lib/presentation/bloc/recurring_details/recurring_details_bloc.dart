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
import 'package:task_manager/domain/usecases/update_existing_recurring_dates_usecase.dart';

part 'recurring_details_event.dart';
part 'recurring_details_state.dart';

class RecurringDetailsBloc
    extends Bloc<RecurringDetailsEvent, RecurringDetailsState> {
  final GetRecurrenceDetailsUsecase getRecurrenceDetailsUsecase;
  final AddScheduledDatesUseCase addScheduledDatesUseCase;
  final ClearScheduledDatesUseCase clearScheduledDatesUseCase;
  final UpdateScheduledDatesUseCase updateScheduledDatesUseCase;

  RecurringDetailsBloc({
    required this.getRecurrenceDetailsUsecase,
    required this.addScheduledDatesUseCase,
    required this.clearScheduledDatesUseCase,
    required this.updateScheduledDatesUseCase,
  }) : super(RecurringDetailsInitial()) {
    on<FetchRecurringTaskDetails>(_onGetRecurrenceDetails);
    on<ScheduleRecurringTaskDates>(_onScheduleRecurringTaskDates);
    on<ClearRecurringTaskDates>(_onClearRecurringTaskDates);
    on<UpdateRecurringTaskDates>(_onUpdateRecurringDates);
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
      // Schedule notifications and update scheduled dates
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
      if (event.frequency == null) {
        emit(RecurringTaskScheduleError(message: 'Frequency is missing.'));
        return;
      }

      final nextScheduledDates = _calculateNextRecurringDates(
          startDate: event.startDate, frequency: event.frequency);

      if (nextScheduledDates.isEmpty) {
        emit(RecurringTaskScheduleError(
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

  // Function to calculate next recurring dates based on frequency
  List<DateTime> _calculateNextRecurringDates({
    required DateTime startDate,
    required Frequency frequency,
  }) {
    List<DateTime> nextDates = [];
    DateTime nextDate = startDate;

    for (int i = 0; i < 7; i++) {
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
