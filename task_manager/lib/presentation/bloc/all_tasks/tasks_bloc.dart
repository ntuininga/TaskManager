import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/core/utils/recurring_task_utils.dart';
import 'package:task_manager/core/utils/task_utils.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
import 'package:task_manager/domain/repositories/recurrence_rules_repository.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';
import 'package:task_manager/domain/repositories/recurring_instance_repository.dart';
import 'package:task_manager/domain/usecases/add_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/bulk_update.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks_by_category.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;
  final RecurringInstanceRepository recurringInstanceRepository;
  final RecurrenceRulesRepository recurringRulesRepository;
  final RecurringTaskRepository recurringTaskRepository;
  final GetTaskByIdUseCase getTaskByIdUseCase;
  final GetTasksByCategoryUseCase getTasksByCategoryUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final DeleteAllTasksUseCase deleteAllTasksUseCase;
  final DeleteTaskCategoryUseCase deleteTaskCategoryUseCase;
  final BulkUpdateTasksUseCase bulkUpdateTasksUseCase;
  final AddScheduledDatesUseCase addScheduledDatesUseCase;

  List<Task> allTasks = [];
  List<Task> displayTasks = [];
  List<Task> recurringInstanceTasks = [];
  Filter currentFilter = Filter(FilterType.uncomplete, null);
  FilterType currentFilterType = FilterType.uncomplete;
  TaskCategory? currentCategory;
  bool hasGeneratedRecurringInstances = false;

  TasksBloc({
    required this.taskRepository,
    required this.recurringInstanceRepository,
    required this.recurringRulesRepository,
    required this.recurringTaskRepository,
    required this.getTaskByIdUseCase,
    required this.getTasksByCategoryUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.deleteAllTasksUseCase,
    required this.deleteTaskCategoryUseCase,
    required this.bulkUpdateTasksUseCase,
    required this.addScheduledDatesUseCase,
  }) : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onApplyFilter);
    on<SortTasks>(_onSortTasks);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<DeleteAllTasks>(_onDeleteAllTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<CategoryChangeEvent>(_onCategoryChange);
    on<BulkUpdateTasks>(_onBulkUpdateTasks);
    on<CompleteTask>(_completeTask);
    on<CompleteRecurringInstance>(_onCompleteRecurringInstance);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> emitSuccessState(Emitter<TasksState> emit) async {
    final baseTasks = await taskRepository.getAllTasks();
    final recurringInstances = await generateDisplayInstances();
    final allTasks = [...baseTasks, ...recurringInstances];

    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(uncompleted);
    final urgent = filterUrgent(uncompleted);
    final overdue = filterOverdue(uncompleted);

    // If a valid state is already active, preserve the current filter
    final currentState = state;
    Filter activeFilter = Filter(FilterType.uncomplete, null);

    if (currentState is SuccessGetTasksState) {
      activeFilter = currentState.activeFilter;
    }

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: uncompleted,
      activeFilter: activeFilter,
      todayCount: today.length,
      urgentCount: urgent.length,
      overdueCount: overdue.length,
    ));
  }

  Future<void> _onRefreshTasks(
      RefreshTasksEvent event, Emitter<TasksState> emit) async {
    try {
      allTasks = await taskRepository.getAllTasks();
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to refresh tasks: $e'));
    }
  }

  Future<void> _onCategoryChange(
      CategoryChangeEvent event, Emitter<TasksState> emit) async {
    try {
      List<Task> tasksWithCategory = [];

      // Fetch tasks that are assigned to the category
      if (event.categoryId != null) {
        tasksWithCategory = await getTasksByCategoryUseCase(event.categoryId!);
      }

      // Handle category deletion scenario
      if (event.category == null) {
        // Update all tasks to remove the category
        for (var task in tasksWithCategory) {
          final updatedTask =
              task.copyWith(taskCategory: null, copyNullValues: true);
          await updateTaskUseCase(updatedTask);

          final index = allTasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            allTasks[index] = updatedTask; // Update local task list
          }
        }

        // After updating tasks, delete the category
        // await deleteTaskCategoryUseCase(event.categoryId!);

        event.onComplete?.call();

        // _updateTaskLists(emit);
      } else {
        // Handle category update scenario
        for (var task in tasksWithCategory) {
          final updatedTask = task.copyWith(taskCategory: event.category);
          await updateTaskUseCase(updatedTask);

          final index = allTasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            allTasks[index] = updatedTask; // Update local task list
          }
        }

        await emitSuccessState(emit);
      }
    } catch (e) {
      emit(ErrorState('Failed to update category: $e'));
    }
  }

  void _completeTask(CompleteTask event, Emitter<TasksState> emit) async {
    try {
      final task = event.taskToComplete;

      final updatedTask = task.copyWith(
        isDone: task.isDone,
        completedDate: task.isDone ? DateTime.now() : null,
      );

      await taskRepository.completeTask(updatedTask);

      if (updatedTask.isDone && updatedTask.id != null) {
        await cancelAllNotificationsForTask(updatedTask.id!);
      }

      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to complete task: $e'));
    }
  }

  void _onCompleteRecurringInstance(
      CompleteRecurringInstance event, Emitter<TasksState> emit) async {
    try {
      final instanceId = event.instanceToComplete.recurringInstanceId;
      if (instanceId == null) {
        emit(const ErrorState('Invalid instance ID'));
        return;
      }

      await recurringInstanceRepository.completeInstance(
          instanceId, DateTime.now());

      // Refresh all tasks from DB
      await emitSuccessState(emit);
    } catch (e) {
      emit(const ErrorState('Failed to complete recurring instance'));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      // No need to mutate any BLoC-level list — just trigger a refresh
      await emitSuccessState(emit);
    } catch (e, stackTrace) {
      print('Failed to get tasks: $e\n$stackTrace');
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  Future<List<Task>> generateDisplayInstances() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<Task> newDisplayTasks = [];

    // Step 1: Fetch uncompleted instances and group by taskId
    final List<RecurringInstance> allInstances =
        await recurringInstanceRepository.getUncompletedInstances();

    final Map<int, List<RecurringInstance>> groupedByTaskId = {};
    for (final instance in allInstances) {
      if (instance.taskId != null && instance.occurrenceDate != null) {
        groupedByTaskId.putIfAbsent(instance.taskId!, () => []).add(instance);
      }
    }

    // Step 2: Process each group
    for (final entry in groupedByTaskId.entries) {
      final int taskId = entry.key;
      final List<RecurringInstance> instances = entry.value;

      if (instances.isEmpty) continue;

      // Sort instances by date
      instances.sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
      final Task baseTask = await taskRepository.getTaskById(taskId);

      RecurringInstance? lastBeforeToday;
      RecurringInstance? nextOnOrAfterToday;

      for (final instance in instances) {
        final DateTime instanceDate = DateTime(
          instance.occurrenceDate!.year,
          instance.occurrenceDate!.month,
          instance.occurrenceDate!.day,
        );

        if (instanceDate.isBefore(today)) {
          lastBeforeToday = instance;
        } else {
          nextOnOrAfterToday ??= instance;
        }
      }

      if (lastBeforeToday != null) {
        newDisplayTasks.add(baseTask.copyWith(
          id: null,
          date: lastBeforeToday.occurrenceDate,
          time: lastBeforeToday.occurrenceTime,
          recurringInstanceId: lastBeforeToday.id,
          isRecurring: false,
          isDone: lastBeforeToday.isDone,
        ));
      }

      if (nextOnOrAfterToday != null &&
          (lastBeforeToday == null ||
              lastBeforeToday.id != nextOnOrAfterToday.id)) {
        newDisplayTasks.add(baseTask.copyWith(
          id: null,
          date: nextOnOrAfterToday.occurrenceDate,
          time: nextOnOrAfterToday.occurrenceTime,
          recurringInstanceId: nextOnOrAfterToday.id,
          isRecurring: false,
          isDone: nextOnOrAfterToday.isDone,
        ));
      }
    }

    return newDisplayTasks;
  }

  Future<void> generateNextInstancesForRecurringTasks() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<RecurringInstance> allInstances =
        await recurringInstanceRepository.getUncompletedInstances();

    final Map<int, List<RecurringInstance>> groupedByTaskId = {};
    for (final instance in allInstances) {
      if (instance.taskId != null && instance.occurrenceDate != null) {
        groupedByTaskId.putIfAbsent(instance.taskId!, () => []).add(instance);
      }
    }

    for (final entry in groupedByTaskId.entries) {
      final int taskId = entry.key;
      final List<RecurringInstance> instances = entry.value;

      instances.sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
      final RecurringInstance lastInstance = instances.last;

      try {
        final Task baseTask = await taskRepository.getTaskById(taskId);
        if (baseTask.recurrenceRuleId == null) continue;

        final RecurrenceRuleset? ruleset = await recurringRulesRepository
            .getRuleById(baseTask.recurrenceRuleId!);
        if (ruleset == null || ruleset.frequency == null) continue;

        DateTime? nextDate = getNextDateByFrequency(
            lastInstance.occurrenceDate!, ruleset.frequency!);

        // Generate all missed instances up to today
        while (nextDate != null && nextDate.isBefore(today)) {
          final RecurringInstance newInstance =
              lastInstance.copyWith(occurrenceDate: nextDate);
          await recurringInstanceRepository.insertInstance(newInstance);

          nextDate = getNextDateByFrequency(nextDate, ruleset.frequency!);
        }
      } catch (e) {
        // Log the error but continue with the next task group
        print('Error generating instance for taskId $taskId: $e');
      }
    }
  }

  DateTime? getNextDateByFrequency(DateTime fromDate, Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return fromDate.add(Duration(days: 1));
      case Frequency.weekly:
        return fromDate.add(Duration(days: 7));
      case Frequency.monthly:
        final nextMonth = DateTime(fromDate.year, fromDate.month + 1, 1);
        final day = fromDate.day;
        final lastDayOfNextMonth =
            DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        return DateTime(
          nextMonth.year,
          nextMonth.month,
          day <= lastDayOfNextMonth ? day : lastDayOfNextMonth,
        );
      case Frequency.yearly:
        final nextYear = fromDate.year + 1;
        final day = fromDate.day;
        final lastDayOfMonthNextYear =
            DateTime(nextYear, fromDate.month + 1, 0).day;
        return DateTime(
          nextYear,
          fromDate.month,
          day <= lastDayOfMonthNextYear ? day : lastDayOfMonthNextYear,
        );
      default:
        return null;
    }
  }

  Future<List<Task>> generateInitialRecurringTasks({
    required Task baseTask,
    required RecurrenceRuleset rule,
    int instanceCount = 7,
  }) async {
    if (baseTask.id == null) {
      throw ArgumentError('Base task must have a valid ID.');
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final TimeOfDay time = baseTask.time ?? const TimeOfDay(hour: 9, minute: 0);

    DateTime occurrenceDate = baseTask.date ?? today;
    final List<Task> generatedTasks = [];

    for (int i = 0; i < instanceCount; i++) {
      final recurringInstance = RecurringInstance(
        taskId: baseTask.id!,
        occurrenceDate: occurrenceDate,
        occurrenceTime: time,
        isDone: false,
      );

      await recurringInstanceRepository.insertInstance(recurringInstance);

      final Task instanceTask = baseTask.copyWith(
        id: null,
        isRecurring: false,
        recurrenceRuleId: null,
        date: occurrenceDate,
        isDone: false,
        createdOn: DateTime.now(),
        updatedOn: DateTime.now(),
      );

      scheduleNotificationForRecurringInstance(
          recurringInstance, baseTask.title!,
          suffix: i);
      generatedTasks.add(instanceTask);
      occurrenceDate = getNextRecurringDate(occurrenceDate, rule.frequency!);
    }

    return generatedTasks;
  }

  Future<void> assignMissingDatesForRecurringTask(Task task) async {
    final currentDate = DateTime.now();

    // Check if task is recurring
    if (task.isRecurring == false) return;

    final int taskId = task.id!;

    final recurringDetails =
        await recurringTaskRepository.fetchDetailsByTaskId(taskId);

    final List<DateTime> missedDates = recurringDetails.missedDates ?? [];

    //Fetch recurrence rule
    final RecurrenceRuleset? recurrenceRuleset =
        await recurringRulesRepository.getRuleById(taskId);
    if (recurrenceRuleset == null) return;

    //Extract Recurrence Rule Details
    final frequency = recurrenceRuleset.frequency;

    DateTime nextDate = task.date ?? DateTime.now();
    if (task.date == null && missedDates.isEmpty) return;
    if (missedDates.isNotEmpty && missedDates.last.isAfter(task.date!)) {
      nextDate = missedDates.last;
    }

    // Iterate through recurrence timeline
    while (true) {
      switch (frequency) {
        case Frequency.daily:
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case Frequency.weekly:
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case Frequency.monthly:
          final daysInMonth = getDaysInMonth(nextDate.year, nextDate.month + 1);
          nextDate = DateTime(nextDate.year, nextDate.month + 1,
              min(nextDate.day, daysInMonth));
          break;
        case Frequency.yearly:
          final daysInMonth = getDaysInMonth(nextDate.year + 1, nextDate.month);
          nextDate = DateTime(nextDate.year + 1, nextDate.month,
              min(nextDate.day, daysInMonth));
          break;
        default:
          return;
      }

      if (nextDate.isAfter(currentDate)) break;

      //Check if after end Date if applicable
      if (missedDates.contains(nextDate)) continue;
      missedDates.add(nextDate);
    }
    // Check for missed occurrences

    // Update task with missed dates
    await recurringTaskRepository.updateMissedDates(taskId, missedDates);

    // Log the Update
    print("Missed Dates for $taskId. -> $missedDates");
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      final taskToAdd = event.taskToAdd;
      final recurrenceRuleset = taskToAdd.recurrenceRuleset;
      final addedTask = await addTaskUseCase.call(event.taskToAdd);

      List<Task> updatedAllTasks = [addedTask];

      if (addedTask.isRecurring && recurrenceRuleset != null) {
        final recurrenceId =
            await recurringRulesRepository.insertRule(recurrenceRuleset);
        addedTask.copyWith(recurrenceRuleId: recurrenceId);
        // Generate and insert recurring instances
        await generateInitialRecurringTasks(
          baseTask: addedTask,
          rule: recurrenceRuleset,
        );
        updatedAllTasks.clear();
      } else {
        await scheduleNotificationByTask(addedTask);
      }

      // Optionally: fetch other existing tasks from DB to get a complete picture
      final existingTasks = await taskRepository.getAllTasks();
      final recurringInstances = await generateDisplayInstances();
      updatedAllTasks.addAll(recurringInstances);

      // Filters (assuming uncompleted, non-recurring for counts)
      final uncompleted = filterUncompletedAndNonRecurring(existingTasks);
      final displayTasks = [...updatedAllTasks, ...uncompleted];
      final today = filterDueToday(uncompleted);
      final urgent = filterUrgent(uncompleted);
      final overdue = filterOverdue(uncompleted);

      emit(SuccessGetTasksState(
        allTasks: existingTasks,
        displayTasks: displayTasks,
        activeFilter: Filter(FilterType.uncomplete, null),
        todayCount: today.length,
        urgentCount: urgent.length,
        overdueCount: overdue.length,
      ));
    } catch (e) {
      emit(ErrorState('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      final updatedTask = event.taskToUpdate;

      // Update task in DB
      await updateTaskUseCase(updatedTask);

      // Cancel and reschedule notifications
      if (updatedTask.id != null) {
        await cancelAllNotificationsForTask(updatedTask.id!);
        await scheduleNotificationByTask(updatedTask);
      }

      if (updatedTask.isRecurring) {
        recurringInstanceRepository
            .deleteInstancesByTaskId(event.taskToUpdate.id!);

        cancelAllNotificationsForTask(event.taskToUpdate.id!);

        generateInitialRecurringTasks(
            baseTask: event.taskToUpdate,
            rule: event.taskToUpdate.recurrenceRuleset!);
      }

      // Recalculate all and emit updated state
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to update task: $e'));
    }
  }

  Future<void> _onBulkUpdateTasks(
      BulkUpdateTasks event, Emitter<TasksState> emit) async {
    try {
      final taskIds = event.taskIds;
      await bulkUpdateTasksUseCase.call(
          taskIds, event.newCategory, event.markComplete);

      // Fetch the updated task list
      // allTasks = await taskRepository.getUncompletedNonRecurringTasks();

      // Update the state with the new list of tasks
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to bulk update tasks: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      // Delete recurring instances if applicable
      if (event.task != null && event.task!.isRecurring) {
        await recurringInstanceRepository.deleteInstancesByTaskId(event.taskId);
        // Optionally also delete the recurrence rule if needed
        // await recurringRulesRepository.deleteRuleByTaskId(event.taskId);
      }

      await deleteTaskUseCase.call(event.taskId);
      await cancelAllNotificationsForTask(event.taskId);

      // Reload everything from DB
      final baseTasks = await taskRepository.getAllTasks();
      final recurringInstances = await generateDisplayInstances();

      final allTasks = [...baseTasks, ...recurringInstances];
      final uncompleted = filterUncompletedAndNonRecurring(allTasks);

      final today = filterDueToday(uncompleted);
      final urgent = filterUrgent(uncompleted);
      final overdue = filterOverdue(uncompleted);

      emit(SuccessGetTasksState(
        allTasks: allTasks,
        displayTasks: uncompleted,
        activeFilter: Filter(FilterType.uncomplete, null),
        todayCount: today.length,
        urgentCount: urgent.length,
        overdueCount: overdue.length,
      ));
    } catch (e) {
      emit(ErrorState('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      await deleteAllTasksUseCase.call();
      await cancelAllNotifications();

      // Emit an empty state
      emit(SuccessGetTasksState(
        allTasks: const [],
        displayTasks: const [],
        activeFilter: Filter(FilterType.uncomplete, null),
        todayCount: 0,
        urgentCount: 0,
        overdueCount: 0,
      ));
    } catch (e) {
      emit(ErrorState('Failed to delete all tasks: $e'));
    }
  }

  void _onApplyFilter(FilterTasks event, Emitter<TasksState> emit) {
    final filter = event.filter;
    final category = event.category;

    final currentState = state;
    if (currentState is! SuccessGetTasksState) return;

    final allTasks = currentState.allTasks;
    final filteredTasks = filterTasks(allTasks, filter, category);

    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(uncompleted);
    final urgent = filterUrgent(uncompleted);
    final overdue = filterOverdue(uncompleted);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: filteredTasks,
      activeFilter: Filter(filter, category),
      todayCount: today.length,
      urgentCount: urgent.length,
      overdueCount: overdue.length,
    ));
  }

  void _onSortTasks(SortTasks event, Emitter<TasksState> emit) {
    final currentState = state;
    if (currentState is! SuccessGetTasksState) return;

    final allTasks = currentState.allTasks;
    final activeFilter = currentState.activeFilter;

    List<Task> sorted = [];

    if (state is SuccessGetTasksState || state is TaskAddedState) {
      final filtered = filterTasks(
          allTasks, activeFilter.filterType, activeFilter.filteredCategory);
      sorted = sortTasks(filtered, event.sortType);
    }

    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(uncompleted);
    final urgent = filterUrgent(uncompleted);
    final overdue = filterOverdue(uncompleted);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: sorted,
      activeFilter: activeFilter,
      todayCount: today.length,
      urgentCount: urgent.length,
      overdueCount: overdue.length,
    ));
  }

  List<Task> getCompletedTodayTasks(List<Task> tasks) {
    final today = DateTime.now();
    return tasks.where((task) {
      return task.isDone &&
          task.completedDate != null &&
          task.completedDate!.isSameDate(today);
    }).toList();
  }
}
