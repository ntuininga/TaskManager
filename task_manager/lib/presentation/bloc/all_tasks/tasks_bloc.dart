import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/core/utils/task_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
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
  List<Task> uncompletedTasks = [];
  List<Task> completedTasks = [];
  List<Task> recurringInstanceTasks = [];
  Filter currentFilter = Filter(FilterType.uncomplete, null);
  bool hasGeneratedRecurringInstances = false;

  TasksBloc({
    required this.taskRepository,
    required this.recurringInstanceRepository,
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
    final all = await taskRepository.getAllTasks();
    final uncomplete = filterUncompletedAndNonRecurring(all);
    final today = uncomplete.where((t) => isToday(t.date)).toList();
    final urgent =
        uncomplete.where((t) => t.urgencyLevel == TaskPriority.high).toList();
    final overdue = uncomplete.where((t) => isOverdue(t.date)).toList();

    allTasks = all;
    displayTasks = uncomplete;

    emit(SuccessGetTasksState(
      allTasks: all,
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

      // Cancel notifications only if marking as completed
      if (newIsDone && task.id != null) {
        await flutterLocalNotificationsPlugin.cancel(task.id!);
      }

      // Refresh tasks from the database after completing the task
      await _refreshTasksFromDatabase(emit);
    } catch (e) {
      emit(ErrorState('Failed to complete task: $e'));
    }
  }

  void _onCompleteRecurringInstance(
      CompleteRecurringInstance event, Emitter<TasksState> emit) async {
    try {
      await recurringInstanceRepository.completeInstance(
          event.instanceId, DateTime.now());

      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to complete recurring instance'));
    }
  }

  Future<void> _refreshTasksFromDatabase(Emitter<TasksState> emit) async {
    try {
      final List<Task> updatedTasks =
          await taskRepository.getUncompletedNonRecurringTasks();

      allTasks = updatedTasks;

      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to refresh tasks from database: $e'));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      completedTasks = await taskRepository.getCompletedTasks();
      allTasks = await taskRepository.getAllTasks();

      final List<RecurringInstance> instances =
          await recurringInstanceRepository.getUncompletedInstances();

      // Generate new instance tasks
      final List<Task> newInstanceTasks =
          await _generateRecurringInstanceTasks(instances);

      for (final task in newInstanceTasks) {
        recurringInstanceTasks.add(task);
      }

      if (recurringInstanceTasks.isNotEmpty) {
        allTasks = [...allTasks, ...recurringInstanceTasks];
      }

      await emitSuccessState(emit);
    } catch (e, stackTrace) {
      print('Failed to get tasks: $e\n$stackTrace');
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  Future<List<Task>> _generateRecurringInstanceTasks(
      List<RecurringInstance> instances) async {
    final List<Task> instanceTasks = [];
    print('Generating recurring tasks...');

    final existingInstanceIds =
        recurringInstanceTasks.map((task) => task.recurringInstanceId);

    print('Existing Instance IDs: $existingInstanceIds');

    // Iterate over each recurring instance
    for (var instance in instances) {
      final instanceId = instance.id;
      final occurrenceDate = instance.occurrenceDate;

      // Ensure valid instance ID and avoid duplicates
      if (instanceId == null || existingInstanceIds.contains(instanceId)) {
        continue;
      }

      if (occurrenceDate != null &&
          (occurrenceDate.isBefore(DateTime.now()) ||
              isToday(occurrenceDate))) {
        final taskId = instance.taskId;

        if (taskId != null) {
          final task = await getTaskByIdUseCase(taskId);

          if (task != null) {
            final instanceTask = task.copyWith(
              id: null, // New ID for recurring instance
              recurringInstanceId: instanceId,
              date: occurrenceDate,
              copyNullValues: true,
            );

            instanceTasks.add(instanceTask);
          } else {
            print('No task found for recurring instance with ID: $taskId');
          }
        } else {
          print('Recurring instance with ID: $instanceId has no task ID');
        }
      }
    }

    return instanceTasks;
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      // Create the task first to get the generated ID
      Task addedTask = await addTaskUseCase.call(event.taskToAdd);
      displayTasks.add(addedTask);

      final all = await taskRepository.getAllTasks();
      final uncomplete = filterUncompletedAndNonRecurring(all);
      final today = uncomplete.where((t) => isToday(t.date)).toList();
      final urgent =
          uncomplete.where((t) => t.urgencyLevel == TaskPriority.high).toList();
      final overdue = uncomplete.where((t) => isOverdue(t.date)).toList();

      emit(TaskAddedState(
        newTask: addedTask,
        displayTasks: displayTasks,
        allTasks: all,
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
      allTasks = await taskRepository.getUncompletedNonRecurringTasks();

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
      await cancelAllNotifications();
      await emitSuccessState(emit);
    } catch (e) {
      emit(ErrorState('Failed to delete all tasks: $e'));
    }
  }

  void _onApplyFilter(FilterTasks event, Emitter<TasksState> emit) {
    final appliedFilter = event.filter;
    print(appliedFilter);
    final filtered = filterTasks(allTasks, appliedFilter, event.category);
    displayTasks = filtered;

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: filtered,
      activeFilter: currentFilter,
      todayCount: filterDueToday(allTasks).length,
      urgentCount: filterUrgent(allTasks).length,
      overdueCount: filterOverdue(allTasks).length,
    ));
    print("Emitted state with ${filtered.length} tasks");
  }

  void _onSortTasks(SortTasks event, Emitter<TasksState> emit) {
    List<Task> tasksToSort = filterUncompletedAndNonRecurring(allTasks);
    List<Task> sorted = sortTasks(tasksToSort, event.sortType);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: sorted,
      activeFilter: currentFilter,
      todayCount: _filterDueToday().where((task) => !task.isDone).length,
      urgentCount: _filterUrgent().where((task) => !task.isDone).length,
      overdueCount: _filterOverdue().where((task) => !task.isDone).length,
    ));
  }

  List<Task> _filterDueToday() =>
      allTasks.where((task) => isToday(task.date) && !task.isDone).toList();
  List<Task> _filterUrgent() => allTasks
      .where((task) => task.urgencyLevel == TaskPriority.high && !task.isDone)
      .toList();

  List<Task> _filterOverdue() => allTasks
      .where((task) => isOverdue(task.date) && task.isDone == false)
      .toList();
  List<Task> getCompletedTodayTasks(List<Task> tasks) {
    final today = DateTime.now();
    return tasks.where((task) {
      return task.isDone &&
          task.completedDate != null &&
          task.completedDate!.isSameDate(today);
    }).toList();
  }
}
