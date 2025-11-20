import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/core/utils/task_utils.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
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
    on<RemoveCategoryFromTasks>(_onRemoveCategoryFromTasks);
    on<DeleteTasksWithCategory>(_deleteTasksWithCategory);
    on<BulkUpdateTasks>(_onBulkUpdateTasks);
    on<CompleteTask>(_completeTask);
    on<CompleteRecurringInstance>(_onCompleteRecurringInstance);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

Future<void> _refreshTasksState(
  Emitter<TasksState> emit,
  TasksState currentState, {
  List<Task>? overrideAllTasks,
}) async {
  // Use override list when provided (e.g., after AddTask)
  final allTasks = overrideAllTasks ?? await taskRepository.getAllTasks();

  // Use uncompleted tasks for derived lists
  final uncompleted = filterUncompletedAndNonRecurring(allTasks);
  final today = filterDueToday(uncompleted);
  final urgent = filterUrgent(uncompleted);
  final overdue = filterOverdue(uncompleted);

  // Preserve categories
  final categories = currentState is SuccessGetTasksState
      ? currentState.allCategories
      : <TaskCategory>[];

  // Group by category
  final tasksByCategoryId = groupTasksByCategory(allTasks, categories);

  // Preserve current active filter
  final activeFilter = currentState is SuccessGetTasksState
      ? currentState.activeFilter
      : Filter(FilterType.uncomplete, null);

  // Apply active filter for display list
  final filteredTasks = filterTasks(
    allTasks,
    activeFilter.filterType,
    activeFilter.filteredCategory,
  );

  emit(
    SuccessGetTasksState(
      allTasks: List.from(allTasks),
      displayTasks: List.from(filteredTasks),
      activeFilter: activeFilter,
      today: List.from(today),
      urgent: List.from(urgent),
      overdue: List.from(overdue),
      tasksByCategoryId: Map.from(tasksByCategoryId),
      allCategories: List.from(categories),
    ),
  );
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

      cats = cats
          .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
          .toList();

      final Map<int, TaskCategory> catById = {
        for (final cat in cats)
          if (cat.id != null) cat.id!: cat,
      };

      final updatedTasks = baseTasks.map((task) {
        final id = task.taskCategory?.id ?? task.id;
        if (id != null && catById.containsKey(id)) {
          return task.copyWith(taskCategory: catById[id]);
        }
        return task;
      }).toList();

      final tasksNeedingUpdate = updatedTasks.where((task) {
        final original = baseTasks.firstWhere((t) => t.id == task.id);
        final originalCatId = original.taskCategory?.id;
        final newCatId = task.taskCategory?.id;
        return originalCatId != newCatId;
      }).toList();

      if (tasksNeedingUpdate.isNotEmpty) {
        for (final task in tasksNeedingUpdate) {
          await taskRepository.updateTask(task);
        }
      }


      final today = filterDueToday(updatedTasks);
      final urgent = filterUrgent(updatedTasks);
      final overdue = filterOverdue(updatedTasks);


      final Map<int, List<Task>> tasksByCategoryId = {};
      for (final task in updatedTasks) {
        final id = task.taskCategory?.id;
        if (id != null) {
          tasksByCategoryId.putIfAbsent(id, () => []).add(task);
        }
      }


      final filteredTasks = filterTasks(
        updatedTasks,
        activeFilter.filterType,
        activeFilter.filteredCategory,
      );

      for (final t in updatedTasks) {
        print('Task ${t.title}: ${t.taskCategory?.colour}');
      }

      emit(SuccessGetTasksState(
        allTasks: List.from(updatedTasks),
        displayTasks: List.from(filteredTasks),
        activeFilter: activeFilter,
        today: List.from(today),
        urgent: List.from(urgent),
        overdue: List.from(overdue),
        tasksByCategoryId: Map.from(tasksByCategoryId),
        allCategories: List.from(cats),
      ));
    } catch (e) {
      emit(ErrorState('Failed to update category: $e'));
    }
  }

  Future<void> _onRemoveCategoryFromTasks(
    RemoveCategoryFromTasks event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final currentState = state;

      await taskRepository.removeCategoryFromTasks(event.categoryId);

      await _refreshTasksState(emit, currentState);
    } catch (e) {
      emit(ErrorState('Failed to remove category from tasks: $e'));
    }
  }

  Future<void> _deleteTasksWithCategory(
    DeleteTasksWithCategory event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final currentState = state;

      // Delete tasks in DB
      await taskRepository.deleteTasksWithCategory(event.categoryId);

      // Refresh state to remove them from the UI
      await _refreshTasksState(emit, currentState);
    } catch (e) {
      emit(ErrorState('Failed to delete tasks with category: $e'));
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
    OnGettingTasksEvent event,
    Emitter<TasksState> emit,
  ) async {
    try {
      final allTasks = await taskRepository.getAllTasks();
      final fetchedCategories = await taskRepository.getAllCategories();

      // Update category references in tasks
      final categoryMap = {
        for (final cat in fetchedCategories) cat.id!: cat,
      };
      for (final task in allTasks) {
        final catId = task.taskCategory?.id;
        if (catId != null && categoryMap.containsKey(catId)) {
          task.taskCategory = categoryMap[catId];
        }
      }

      final uncompleted = filterUncompletedAndNonRecurring(allTasks);
      final today = filterDueToday(uncompleted);
      final urgent = filterUrgent(uncompleted);
      final overdue = filterOverdue(uncompleted);

      final Map<int, List<Task>> tasksByCategory = {
        for (final cat in fetchedCategories) cat.id!: [],
      };
      for (final task in allTasks) {
        final category = task.taskCategory?.id;
        if (category != null) {
          tasksByCategory.putIfAbsent(category, () => []).add(task);
        }
      }

      emit(SuccessGetTasksState(
        allTasks: allTasks,
        displayTasks: uncompleted,
        activeFilter: currentFilter,
        today: today,
        urgent: urgent,
        overdue: overdue,
        tasksByCategoryId: tasksByCategory,
        allCategories: fetchedCategories,
      ));
    } catch (e) {
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      final taskToAdd = event.taskToAdd;
      final addedTask = await taskRepository.addTask(taskToAdd);
      await scheduleNotificationByTask(addedTask);

      final currentState = state;

      if (currentState is SuccessGetTasksState) {
        // Put new task at the top (your desired behavior)
        final patchedAllTasks = [addedTask, ...currentState.allTasks];

        // Rebuild everything using the patched list
        await _refreshTasksState(
          emit,
          currentState,
          overrideAllTasks: patchedAllTasks,
        );
      } else {
        // Fallback: full refresh from DB
        await _refreshTasksState(emit, state);
      }
    } catch (e) {
      emit(ErrorState('Failed to add task: $e'));
    }
  }


Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
  try {
    final taskToUpdate = event.taskToUpdate;
    final updatedTask = await taskRepository.updateTask(taskToUpdate);

    // Cancel and reschedule notifications
    if (updatedTask.id != null && !updatedTask.isRecurring) {
      await cancelAllNotificationsForTask(updatedTask.id!);
      await scheduleNotificationByTask(updatedTask);
    }

    if (state is SuccessGetTasksState) {
      final currentState = state as SuccessGetTasksState;

      final updatedAllTasks = currentState.allTasks.map((t) {
        return t.id == updatedTask.id ? updatedTask : t;
      }).toList();

      final updatedTasksByCategory =
          groupTasksByCategory(updatedAllTasks, currentState.allCategories);

      final updatedDueTodayTasks = filterDueToday(updatedAllTasks);
      final updatedUrgentTasks = filterUrgent(updatedAllTasks);
      final updatedOverdueTasks = filterOverdue(updatedAllTasks);



      emit(currentState.copyWith(
        allTasks: updatedAllTasks,
        tasksByCategory: updatedTasksByCategory,
        today: updatedDueTodayTasks,
        urgent: updatedUrgentTasks,
        overdue: updatedOverdueTasks,
      ));
    }
  } catch (e) {
    emit(ErrorState('Failed to update task: $e'));
  }
}





  Future<void> _onBulkUpdateTasks(
      BulkUpdateTasks event, Emitter<TasksState> emit) async {
    try {

      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to bulk update tasks: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.deleteTaskById(event.taskId);
      await cancelAllNotificationsForTask(event.taskId);

      await _refreshTasksState(emit, state);
    } catch (e) {
      emit(ErrorState('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      final Map<int, List<Task>> tasksByCategory = {};

      await taskRepository.deleteAllTasks();
      await cancelAllNotifications();

      emit(SuccessGetTasksState(
          allTasks: const [],
          displayTasks: const [],
          activeFilter: Filter(FilterType.uncomplete, null),
          today: const [],
          urgent: const [],
          overdue: const [],
          tasksByCategoryId: tasksByCategory,
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

    final filteredTasks = filterTasks(allTasks, filterType, category);

    final today = filterDueToday(allTasks);
    final urgent = filterUrgent(allTasks);
    final overdue = filterOverdue(allTasks);

    final Map<int, List<Task>> categorizedTasks = {
      for (final cat in currentState.allCategories) cat.id!: [],
    };
    for (final task in allTasks) {
      final taskCat = task.taskCategory?.id;
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
      tasksByCategoryId: categorizedTasks,
      allCategories: currentState.allCategories,
    ));
  }

  Map<int, List<Task>> groupTasksByCategory(
    List<Task> allTasks,
    List<TaskCategory> allCategories,
  ) {
    final Map<int, List<Task>> categorizedTasks = {
      for (final cat in allCategories)
        if (cat.id != null) cat.id!: [],
    };

    for (final task in allTasks) {
      final categoryId = task.taskCategory?.id;
      if (categoryId != null) {
        categorizedTasks.putIfAbsent(categoryId, () => []).add(task);
      }
    }

    return categorizedTasks;
  }

  void _onSortTasks(SortTasks event, Emitter<TasksState> emit) {
    final currentState = state;
    if (currentState is! SuccessGetTasksState) return;

    final allTasks = currentState.allTasks;
    final activeFilter = currentState.activeFilter;

    final filtered = filterTasks(
      allTasks,
      activeFilter.filterType,
      activeFilter.filteredCategory,
    );

    final sorted = sortTasks(filtered, event.sortType);

    final uncompleted = filterUncompletedAndNonRecurring(allTasks);
    final today = filterDueToday(uncompleted);
    final urgent = filterUrgent(uncompleted);
    final overdue = filterOverdue(uncompleted);
    final tasksByCategory = groupTasksByCategory(allTasks, allCategories);

    emit(SuccessGetTasksState(
      allTasks: allTasks,
      displayTasks: sorted,
      activeFilter: activeFilter,
      today: today,
      urgent: urgent,
      overdue: overdue,
      tasksByCategoryId: tasksByCategory,
      allCategories: currentState.allCategories,
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
