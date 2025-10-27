import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/core/utils/task_utils.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
import 'package:task_manager/domain/repositories/category_repository.dart';
import 'package:task_manager/domain/repositories/recurrence_rules_repository.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';
import 'package:task_manager/domain/repositories/recurring_instance_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;
  final CategoryRepository categoryRepository;
  final RecurringInstanceRepository recurringInstanceRepository;
  final RecurrenceRulesRepository recurringRulesRepository;
  final RecurringTaskRepository recurringTaskRepository;

  List<Task> allTasks = [];
  List<Task> displayTasks = [];
  List<Task> recurringInstanceTasks = [];
  List<TaskCategory> allCategories = [];
  Filter currentFilter = Filter(FilterType.uncomplete, null);
  FilterType currentFilterType = FilterType.uncomplete;
  TaskCategory? currentCategory;
  bool hasGeneratedRecurringInstances = false;

  TasksBloc({
    required this.taskRepository,
    required this.categoryRepository,
    required this.recurringInstanceRepository,
    required this.recurringRulesRepository,
    required this.recurringTaskRepository,
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

  Future<void> _refreshTasksState(
      Emitter<TasksState> emit, TasksState currentState) async {
    final allTasks = await taskRepository.getAllTasks();

    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(allTasks);
    final urgent = filterUrgent(allTasks);
    final overdue = filterOverdue(allTasks);

    final Map<TaskCategory, List<Task>> categorizedTasks = {
      for (final cat in allCategories) cat: [],
    };
    for (final task in allTasks) {
      final category = task.taskCategory;
      if (category != null) {
        categorizedTasks.putIfAbsent(category, () => []).add(task);
      }
    }

    // Preserve active filter from current state if available
    Filter activeFilter = Filter(FilterType.uncomplete, null);
    if (currentState is SuccessGetTasksState) {
      activeFilter = currentState.activeFilter;
    }

    final filteredTasks = filterTasks(
        allTasks, activeFilter.filterType, activeFilter.filteredCategory);

    emit(SuccessGetTasksState(
      allTasks: List.from(allTasks),
      displayTasks: filteredTasks,
      activeFilter: activeFilter,
      today: today,
      urgent: urgent,
      overdue: overdue,
      tasksByCategory: categorizedTasks,
      allCategories: allCategories,
    ));
  }

  Future<void> _onRefreshTasks(
      RefreshTasksEvent event, Emitter<TasksState> emit) async {
    try {
      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to refresh tasks: $e'));
    }
  }

Future<void> _onCategoryChange(
    CategoryChangeEvent event, Emitter<TasksState> emit) async {
  try {
    if (event.category == null) return;
    final updatedCategory = event.category!;

    // 1) Load base data
    List<Task> baseTasks;
    List<TaskCategory> cats;
    Filter activeFilter = Filter(FilterType.uncomplete, null);

    if (state is SuccessGetTasksState) {
      final s = state as SuccessGetTasksState;
      baseTasks = s.allTasks;
      cats = s.allCategories;
      activeFilter = s.activeFilter;
    } else {
      baseTasks = await taskRepository.getAllTasks();
      cats = await categoryRepository.getAllCategories();
    }

    // 2) Replace the updated category in the categories list
    cats = cats.map((c) => c.id == updatedCategory.id ? updatedCategory : c).toList();

    // 3) Build canonical id -> TaskCategory map
    final Map<int, TaskCategory> catById = {
      for (final cat in cats) if (cat.id != null) cat.id!: cat,
    };

    // 4) Patch tasks to reference canonical category instance
    final updatedTasks = baseTasks.map((task) {
      final id = task.taskCategory?.id ?? task.id;
      if (id != null && catById.containsKey(id)) {
        return task.copyWith(taskCategory: catById[id]);
      }
      return task;
    }).toList();

    // 5) Recompute filters
    final uncompleted = filterUncompletedAndNonRecurring(updatedTasks);
    final today = filterDueToday(updatedTasks);
    final urgent = filterUrgent(updatedTasks);
    final overdue = filterOverdue(updatedTasks);

    // 6) Group tasks by category ID, then map back to TaskCategory for UI
    final Map<int, List<Task>> tasksByCategoryId = {};
    for (final task in updatedTasks) {
      final id = task.taskCategory?.id;
      if (id != null) {
        tasksByCategoryId.putIfAbsent(id, () => []).add(task);
      }
    }

    final Map<TaskCategory, List<Task>> categorizedTasks = {
      for (final entry in catById.entries)
        entry.value: tasksByCategoryId[entry.key] ?? [],
    };

    // 7) Filtered tasks according to current filter
    final filteredTasks = filterTasks(
      updatedTasks,
      activeFilter.filterType,
      activeFilter.filteredCategory,
    );

    // 8) Emit updated state
    emit(SuccessGetTasksState(
      allTasks: updatedTasks,
      displayTasks: filteredTasks,
      activeFilter: activeFilter,
      today: today,
      urgent: urgent,
      overdue: overdue,
      tasksByCategory: categorizedTasks,
      allCategories: cats,
    ));
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

      await _refreshTasksState(emit, state);
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
      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(const ErrorState('Failed to complete recurring instance'));
    }
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      // generateNextInstancesForRecurringTasks();

      final allTasks = await taskRepository.getAllTasks();

      final fetchedCategories = await taskRepository.getAllCategories();
      allCategories = fetchedCategories;

      final uncompleted = filterUncompletedAndNonRecurring(allTasks);
      final today = filterDueToday(uncompleted);
      final urgent = filterUrgent(uncompleted);
      final overdue = filterOverdue(uncompleted);

      final Map<TaskCategory, List<Task>> tasksByCategory = {
        for (final cat in allCategories) cat: [],
      };
      for (final task in allTasks) {
        final category = task.taskCategory;
        if (category != null) {
          tasksByCategory.putIfAbsent(category, () => []).add(task);
        }
      }

      emit(SuccessGetTasksState(
          allTasks: allTasks,
          displayTasks: uncompleted, // default display
          activeFilter: currentFilter, // or whatever your default is
          today: today,
          urgent: urgent,
          overdue: overdue,
          tasksByCategory: tasksByCategory,
          allCategories: fetchedCategories));
    } catch (e, stackTrace) {
      print('Failed to get tasks: $e\n$stackTrace');
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      final taskToAdd = event.taskToAdd;
      // final recurrenceRuleset = taskToAdd.recurrenceRuleset;

      Task addedTask;

      final Map<TaskCategory, List<Task>> tasksByCategory = {};

      addedTask = await taskRepository.addTask(taskToAdd);
      await scheduleNotificationByTask(addedTask);

      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      final taskToUpdate = event.taskToUpdate;

      // Update task in DB
      final updatedTask = await taskRepository.updateTask(taskToUpdate);

      // Cancel and reschedule notifications
      if (updatedTask.id != null && !updatedTask.isRecurring) {
        await cancelAllNotificationsForTask(updatedTask.id!);
        await scheduleNotificationByTask(updatedTask);
      }

      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to update task: $e'));
    }
  }

  Future<void> _onBulkUpdateTasks(
      BulkUpdateTasks event, Emitter<TasksState> emit) async {
    try {
      final taskIds = event.taskIds;
      // await bulkUpdateTasksUseCase.call(
      //     taskIds, event.newCategory, event.markComplete);

      // Fetch the updated task list
      // allTasks = await taskRepository.getUncompletedNonRecurringTasks();

      // Update the state with the new list of tasks
      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to bulk update tasks: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      final Map<TaskCategory, List<Task>> tasksByCategory = {};

      await taskRepository.deleteTaskById(event.taskId);
      await cancelAllNotificationsForTask(event.taskId);

      // Reload everything from DB
      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      final Map<TaskCategory, List<Task>> tasksByCategory = {};

      await taskRepository.deleteAllTasks();
      await cancelAllNotifications();

      // Emit an empty state
      emit(SuccessGetTasksState(
          allTasks: const [],
          displayTasks: const [],
          activeFilter: Filter(FilterType.uncomplete, null),
          today: const [],
          urgent: const [],
          overdue: const [],
          tasksByCategory: tasksByCategory,
          allCategories: allCategories));
    } catch (e) {
      emit(ErrorState('Failed to delete all tasks: $e'));
    }
  }

  void _onApplyFilter(FilterTasks event, Emitter<TasksState> emit) {
    final currentState = state;
    if (currentState is! SuccessGetTasksState) return;

    final filterType = event.filter;
    final category = event.category;

    final allTasks = currentState.allTasks;

    // Apply filter
    final filteredTasks = filterTasks(allTasks, filterType, category);

    // Keep these consistent with your refresh logic (use allTasks, not uncompleted)
    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(allTasks);
    final urgent = filterUrgent(allTasks);
    final overdue = filterOverdue(allTasks);

    // Build categorized tasks map
    final Map<TaskCategory, List<Task>> categorizedTasks = {
      for (final cat in currentState.allCategories) cat: [],
    };
    for (final task in allTasks) {
      final taskCat = task.taskCategory;
      if (taskCat != null) {
        categorizedTasks.putIfAbsent(taskCat, () => []).add(task);
      }
    }

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: filteredTasks,
      activeFilter: Filter(filterType, category),
      today: today,
      urgent: urgent,
      overdue: overdue,
      tasksByCategory: categorizedTasks,
      allCategories: currentState.allCategories,
    ));
  }

  void _onSortTasks(SortTasks event, Emitter<TasksState> emit) {
    final currentState = state;
    if (currentState is! SuccessGetTasksState) return;

    final allTasks = currentState.allTasks;
    final activeFilter = currentState.activeFilter;

    List<Task> sorted = [];
    final Map<TaskCategory, List<Task>> tasksByCategory = {};

    if (state is SuccessGetTasksState) {
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
        today: today,
        urgent: urgent,
        overdue: overdue,
        tasksByCategory: tasksByCategory,
        allCategories: allCategories));
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
