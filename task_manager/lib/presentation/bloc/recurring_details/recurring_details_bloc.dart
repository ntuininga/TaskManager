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

      // Identify missed dates
      final missedDates = checkForMissedDates(details);

      // Ensure missedDates is not null and add new missed dates
      final List<DateTime> newMissedDates = [
        ...(details.missedDates ?? []),
        ...missedDates
      ];

      // Ensure scheduledDates is not null and remove missed dates
      final List<DateTime> updatedScheduledDates =
          (details.scheduledDates ?? [])
              .where((date) => !missedDates.contains(date))
              .toList();

      // Update scheduled dates in the database
      await updateScheduledDatesUseCase(
          taskId: event.taskId,
          newScheduledDates: updatedScheduledDates,
          newMissedDates: newMissedDates);

      emit(RecurringTaskDetailsLoaded(
          details: details.copyWith(
              scheduledDates: updatedScheduledDates,
              missedDates: newMissedDates)));
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
      final task = event.task.copyWith();

      // Fetch the recurrence details using the task's ID
      final details = await getRecurrenceDetailsUsecase(task.id!);

      // If no recurrence details exist, schedule new dates from scratch
      if (details.scheduledDates == null || details.scheduledDates!.isEmpty) {
        // If no scheduled dates exist, create new ones
        List<DateTime> newScheduledDates = _calculateNextRecurringDates(
            startDate: DateTime.now(),
            frequency: task.recurrenceRuleset!.frequency!,
            count: 7, // or any number of recurring dates you need
            includeStartDate: true);

        // Add these new dates to the database
        await updateScheduledDatesUseCase(
            taskId: task.id!, newScheduledDates: newScheduledDates);

        // Schedule notifications for the new recurring task dates
        await scheduleNotificationsForRecurringTask(task, newScheduledDates);

        // Emit success state with new dates
        emit(RecurringTaskScheduled(nextScheduledDates: newScheduledDates));

        return; // No need to do further processing since we just added new dates
      }

        // Get the list of scheduled dates for this task
        List<DateTime> scheduledDates = List.from(details.scheduledDates!);

        // Determine the completed date (latest date before current time)
        DateTime completedDate = event.completedDate ??
            scheduledDates.reduce(
                (a, b) => a.isBefore(b) && b.isBefore(DateTime.now()) ? b : a);

        // Remove the completed date from scheduled dates
        scheduledDates.remove(completedDate);

        // Add the completed date to the database
        await addCompletedDateUseCase(task.id!, completedDate);

        List<DateTime> nextScheduledDates = [];

        // Ensure there are enough future dates
        if (scheduledDates.length < 7) {
          int count = 7 - scheduledDates.length;
          nextScheduledDates = _calculateNextRecurringDates(
              startDate: scheduledDates.isNotEmpty ? scheduledDates.last : DateTime.now(),
              frequency: task.recurrenceRuleset!.frequency!,
              count: count,
              includeStartDate: false);
        }

        // Combine the existing scheduled dates with new future dates
        scheduledDates.addAll(nextScheduledDates);

        // Update the scheduled dates in the database
        await updateScheduledDatesUseCase(
            taskId: task.id!, newScheduledDates: scheduledDates);

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
    bool includeStartDate =
        true, // Option to include startDate, defaults to true
  }) {
    List<DateTime> nextDates = [];
    DateTime nextDate = startDate;

    // If includeStartDate is true, add the startDate to the list
    if (includeStartDate) {
      nextDates.add(nextDate);
    }

    // Generate the subsequent dates starting from the nextDate
    for (int i = (includeStartDate ? 1 : 0); i < count; i++) {
      // Increment to calculate the next date based on the frequency
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

      nextDates.add(nextDate); // Add the next calculated date
    }

    return nextDates;
  }

  List<DateTime> checkForMissedDates(RecurringTaskDetails details) {
    List<DateTime> missedDates = [];

    DateTime today = DateTime.now();

    List<DateTime> completedOnDates = details.completedOnDates ?? [];

    if (details.scheduledDates != null) {
      for (var expectedDate in details.scheduledDates!) {
        if (expectedDate.isBefore(today) &&
            !completedOnDates.contains(expectedDate)) {
          missedDates.add(expectedDate);
        }
      }
    }

    return missedDates;
  }
}
