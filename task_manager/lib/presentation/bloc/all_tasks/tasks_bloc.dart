import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/core/utils/recurring_task_utils.dart';
import 'package:task_manager/core/utils/task_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
import 'package:task_manager/domain/repositories/recurrence_rules_repository.dart';
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
    // final all = await taskRepository.getAllTasks();
    final uncomplete = filterUncompletedAndNonRecurring(allTasks);
    final today = uncomplete.where((t) => isToday(t.date)).toList();
    final urgent =
        uncomplete.where((t) => t.urgencyLevel == TaskPriority.high).toList();
    final overdue = uncomplete.where((t) => isOverdue(t.date)).toList();

    displayTasks = List.from(displayTasks);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: displayTasks,
      activeFilter: currentFilter,
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
      Task task = event.taskToComplete;

      final bool newIsDone = task.isDone;
      final completedTask = task.copyWith(
        isDone: newIsDone,
        completedDate: newIsDone ? DateTime.now() : null,
      );

      // Update the task in the database
      await taskRepository.completeTask(completedTask);

      final allTasksIndex = allTasks.indexWhere((t) => t.id == task.id);
      if (allTasksIndex != -1) {
        Task updatedDisplayTask = task.copyWith();
        allTasks[allTasksIndex] = updatedDisplayTask;
      }
      displayTasks.removeWhere((t) => t.id == task.id);

      // Cancel notifications only if marking as completed
      if (newIsDone && task.id != null) {
        await flutterLocalNotificationsPlugin.cancel(task.id!);
      }

      // Refresh tasks from the database after completing the task
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to complete task: $e'));
    }
  }

  void _onCompleteRecurringInstance(
      CompleteRecurringInstance event, Emitter<TasksState> emit) async {
    try {
      await recurringInstanceRepository.completeInstance(
          event.instanceId, DateTime.now());

      final recurring = await _generateRecurringInstanceTasks();

      allTasks = [...allTasks, ...recurring];
      displayTasks = [...displayTasks, ...recurring];

      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to complete recurring instance'));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      allTasks = await taskRepository.getAllTasks();
      displayTasks = filterUncompletedAndNonRecurring(allTasks);

      // Generate new instance tasks
      final List<Task> generatedInstances =
          await _generateFutureTaskInstances();

      allTasks = [...allTasks, ...generatedInstances];
      displayTasks = [...displayTasks, ...generatedInstances];

      await emitSuccessState(emit);
    } catch (e, stackTrace) {
      print('Failed to get tasks: $e\n$stackTrace');
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  Future<List<Task>> _generateFutureTaskInstances() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<Task> generatedTempTasks = [];

    // Step 1: Pull saved instances and group by taskId
    final List<RecurringInstance> allInstances =
        await recurringInstanceRepository.getUncompletedInstances();
    final Map<int, List<RecurringInstance>> groupedByTaskId = {};
    print(allInstances.length);

    for (final instance in allInstances) {
      if (instance.taskId != null) {
        groupedByTaskId.putIfAbsent(instance.taskId!, () => []).add(instance);
      }
    }

    for (final entry in groupedByTaskId.entries) {
      final int taskId = entry.key;
      final List<RecurringInstance> instances = entry.value;

      // Step 2: Sort instances by occurrenceDate and pull closest
      instances.sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
      final RecurringInstance closestInstance = instances.first;

      // Step 3: Fetch base task
      final Task baseTask = await taskRepository.getTaskById(taskId);

      // Step 4: Set startDate
      DateTime startDate = closestInstance.occurrenceDate!;
      if (startDate.isBefore(today)) {
        // OK
      } else {
        continue;
      }

      // Step 5: Fetch recurrence rule
      final RecurrenceRuleset? rule =
          await recurringRulesRepository.getRuleById(baseTask.id!);
      if (rule == null) continue;

      DateTime generateDate = startDate;

      // Step 6: Generate tasks until generateDate > today

// Collect existing instance dates for this task
      final Set<DateTime> existingDates = instances
          .map((e) => DateTime(e.occurrenceDate!.year, e.occurrenceDate!.month,
              e.occurrenceDate!.day))
          .toSet();

      bool addedNextFuture = false;

      while (true) {
        final isPastOrToday = !generateDate.isAfter(today);

        final Task newTask = baseTask.copyWith(
          id: null,
          date: generateDate,
          isRecurring: false,
          recurringInstanceId: closestInstance.id,
          isDone: false,
          createdOn: DateTime.now(),
          updatedOn: DateTime.now(),
        );

        final normalizedGenerateDate =
            DateTime(generateDate.year, generateDate.month, generateDate.day);

        if (isPastOrToday) {
          if (!existingDates.contains(normalizedGenerateDate)) {
            final RecurringInstance newInstance = RecurringInstance(
              taskId: baseTask.id,
              occurrenceDate: generateDate,
              occurrenceTime: baseTask.time,
              isDone: false,
            );
            await recurringInstanceRepository.insertInstance(newInstance);
          }
          generatedTempTasks.add(newTask);
        } else if (!addedNextFuture) {
          generatedTempTasks.add(newTask);
          addedNextFuture = true;
          break;
        } else {
          break;
        }

        generateDate = getNextRecurringDate(generateDate, rule.frequency!);
      }
    }

    return generatedTempTasks;
  }

  Future<List<Task>> _generateRecurringInstanceTasks() async {
    final List<RecurringInstance> instances =
        await recurringInstanceRepository.getUncompletedInstances();
    final List<Task> instanceTasks = [];
    print('Generating recurring tasks...');

    final existingInstanceIds =
        recurringInstanceTasks.map((t) => t.recurringInstanceId).toSet();

    // Group by taskId
    final Map<int, List<RecurringInstance>> groupedByTaskId = {};
    for (final instance in instances) {
      if (instance.taskId != null) {
        groupedByTaskId.putIfAbsent(instance.taskId!, () => []).add(instance);
      }
    }

    for (final entry in groupedByTaskId.entries) {
      final taskInstances =
          entry.value.where((i) => i.occurrenceDate != null).toList();

      if (taskInstances.isEmpty) continue;

      taskInstances
          .sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
      final closest = taskInstances.first;

      if (existingInstanceIds.contains(closest.id)) continue;

      final task = await taskRepository.getTaskById(closest.taskId!);

      // if (taskInstances.length < 7) {
      //   final taskId = entry.key;

      //   // Fetch recurrence rule
      //   final rule = await recurringRulesRepository.getRuleById(taskId);
      //   if (rule == null) continue;

      //   // Refill instances
      //   final newEntities = await refillRecurringInstances(
      //     recurrenceRuleset: rule,
      //     startDate: taskInstances
      //         .map((e) => e.occurrenceDate!)
      //         .reduce((a, b) => a.isAfter(b) ? a : b),
      //     time: taskInstances.first.occurrenceTime ?? TimeOfDay(hour: 9, minute: 0),
      //     taskId: taskId,
      //     existingInstances: taskInstances.map((e) => e.toEntity()).toList(),
      //   );

      //   // Insert new instances
      //   if (newEntities.isNotEmpty) {
      //     await recurringInstanceRepository.insertInstancesBatch(
      //       newEntities.map(RecurringInstance.fromEntity).toList(),
      //     );
      //     // Update the list with newly generated instances
      //     taskInstances.addAll(
      //       newEntities.map(RecurringInstance.fromEntity),
      //     );
      //   }
      // }

      final instanceTask = task.copyWith(
        id: null,
        isRecurring: false,
        recurringInstanceId: closest.id,
        date: closest.occurrenceDate,
        copyNullValues: true,
      );

      instanceTasks.add(instanceTask);
    }

    return instanceTasks;
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      // Create the task first to get the generated ID
      Task addedTask = await addTaskUseCase.call(event.taskToAdd);

      displayTasks.add(addedTask);
      allTasks.add(addedTask);

      final nonRecurring = filterUncompletedAndNonRecurring(allTasks);

      final today = filterDueToday(nonRecurring);
      final urgent = filterUrgent(nonRecurring).toList();
      final overdue = filterOverdue(nonRecurring).toList();

      if (addedTask.isRecurring) {
        final recurring = await _generateRecurringInstanceTasks();
        if (addedTask.recurrenceRuleset != null) {
          recurringRulesRepository.insertRule(addedTask.recurrenceRuleset!);
        }
        allTasks = [...allTasks, ...recurring];
        displayTasks = [...displayTasks, ...recurring];
      }

      emit(TaskAddedState(
        newTask: addedTask,
        displayTasks: displayTasks,
        allTasks: allTasks,
        activeFilter: currentFilter,
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
      final index =
          allTasks.indexWhere((task) => task.id == event.taskToUpdate.id);
      if (index != -1) {
        Task updatedTask = event.taskToUpdate.copyWith();

        allTasks[index] = updatedTask;

        final displayIndex =
            displayTasks.indexWhere((task) => task.id == event.taskToUpdate.id);
        if (displayIndex != -1) {
          Task updatedDisplayTask = event.taskToUpdate.copyWith();
          displayTasks[displayIndex] = updatedDisplayTask;
        }

        await updateTaskUseCase(updatedTask);

        // Update the task lists and emit state
        await emitSuccessState(emit);
      }
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
      await deleteTaskUseCase.call(event.id);
      allTasks.removeWhere((task) => task.id == event.id);
      displayTasks.removeWhere((task) => task.id == event.id);
      await cancelAllNotificationsForTask(event.id);
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      await deleteAllTasksUseCase.call();
      allTasks.clear();
      displayTasks.clear();
      await cancelAllNotifications();
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to delete all tasks: $e'));
    }
  }

  void _onApplyFilter(FilterTasks event, Emitter<TasksState> emit) {
    print("apply");
    final appliedFilter = event.filter;
    final filtered = filterTasks(allTasks, appliedFilter, event.category);

    displayTasks = filtered;
    currentFilterType = appliedFilter;
    currentCategory = event.category;

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: filtered,
      activeFilter: currentFilter,
      todayCount: filterDueToday(allTasks).length,
      urgentCount: filterUrgent(allTasks).length,
      overdueCount: filterOverdue(allTasks).length,
    ));
  }

  void _onSortTasks(SortTasks event, Emitter<TasksState> emit) async {
    final filtered = filterTasks(allTasks, currentFilterType, currentCategory);
    List<Task> sorted = sortTasks(filtered, event.sortType);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: sorted,
      activeFilter: currentFilter,
      todayCount: filterDueToday(allTasks).length,
      urgentCount: filterUrgent(allTasks).length,
      overdueCount: filterOverdue(allTasks).length,
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
