import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/bulk_update.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks_by_category.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final GetTaskByIdUseCase getTaskByIdUseCase;
  final GetTasksByCategoryUseCase getTasksByCategoryUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final DeleteAllTasksUseCase deleteAllTasksUseCase;
  final DeleteTaskCategoryUseCase deleteTaskCategoryUseCase;
  final BulkUpdateTasksUseCase bulkUpdateTasksUseCase;

  List<Task> allTasks = [];
  Filter currentFilter = Filter(FilterType.uncomplete, null);

  TasksBloc({
    required this.getTaskUseCase,
    required this.getTaskByIdUseCase,
    required this.getTasksByCategoryUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.deleteAllTasksUseCase,
    required this.deleteTaskCategoryUseCase,
    required this.bulkUpdateTasksUseCase,
  }) : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<DeleteAllTasks>(_onDeleteAllTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
    on<CategoryChangeEvent>(_onCategoryChange);
    on<BulkUpdateTasks>(_onBulkUpdateTasks);
    on<CompleteTask>(_completeTask);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _onRefreshTasks(
      RefreshTasksEvent event, Emitter<TasksState> emit) async {
    try {
      allTasks = await getTaskUseCase.call();
      _updateTaskLists(emit);
      add(const FilterTasks(filter: FilterType.uncomplete));
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

        _updateTaskLists(emit);
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

        _updateTaskLists(emit);
      }
    } catch (e) {
      emit(ErrorState('Failed to update category: $e'));
    }
  }

  void _completeTask(CompleteTask event, Emitter<TasksState> emit) async {
    try {
      Task task = event.taskToComplete;

      if (task.recurrenceRuleset != null) {
        final date = task.nextOccurrence;
        // final nextDate =
        //     getNextRecurringDate(date!, event.taskToComplete.recurrenceType!);
        final updatedTask = task.copyWith(
          date: date,
          // nextOccurrence: nextDate,
          isDone: false,
        );

        // Update the task with the next occurrence
        await updateTaskUseCase(updatedTask);

        // Reschedule the notification
        await scheduleNotificationByTask(updatedTask);

        // Update local list
        final index = allTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          allTasks[index] = updatedTask;
        }
        
      } else {
        final completedTask =
            task.copyWith(isDone: task.isDone, completedDate: task.isDone ? DateTime.now() : null);
        await updateTaskUseCase(completedTask);

        // Cancel any associated notifications
        if (task.isDone){
          await flutterLocalNotificationsPlugin.cancel(task.id!);
        }

        final index = allTasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          allTasks[index] = completedTask;
        }

        // Update local list
        // allTasks.removeWhere((t) => t.id == task.id);
      }
      // Update the task lists and emit state
      _updateTaskLists(emit);

    } catch (e) {
      emit(ErrorState('Failed to complete task: $e'));
    }
  }

  void _updateTaskLists(Emitter<TasksState> emit) {
    emit(SuccessGetTasksState(
      allTasks: allTasks,
      dueTodayTasks: _filterDueToday(),
      urgentTasks: _filterUrgent(),
      uncompleteTasks: _filterUncompleted(),
      completeTasks: _filterCompleted(),
      filteredTasks: _applyFilter(currentFilter),
      activeFilter: currentFilter,
      todayCount: _filterDueToday().where((task) => !task.isDone).length,
      urgentCount: _filterUrgent().where((task) => !task.isDone).length,
      overdueCount: _filterOverdue().where((task) => !task.isDone).length,
    ));
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      allTasks = await getTaskUseCase.call();
      _updateTaskLists(emit);
      add(const FilterTasks(filter: FilterType.uncomplete));
    } catch (e) {
      emit(ErrorState('Failed to get tasks: $e'));
    }
  }

  void _onFilterTasksEvent(FilterTasks event, Emitter<TasksState> emit) {
    currentFilter = Filter(event.filter, event.category);
    _updateTaskLists(emit);
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      Task task = event.taskToAdd;

      if (task.recurrenceRuleset != null && task.date != null) {
        // task = task.copyWith(
        //     nextOccurrence:
        //         getNextRecurringDate(task.date!, task.recurrenceType!));
      }

      Task addedTask = await addTaskUseCase.call(task);
      allTasks.add(addedTask);
      await scheduleNotificationByTask(addedTask);
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      final index =
          allTasks.indexWhere((task) => task.id == event.taskToUpdate.id);
      if (index != -1) {
        Task updatedTask = event.taskToUpdate;

        // Update nextOccurrence if the task is recurring
        // if (updatedTask.recurrenceType != null) {
        //   updatedTask = updatedTask.copyWith(
        //     nextOccurrence: getNextRecurringDate(
        //       updatedTask.date ?? DateTime.now(),
        //       updatedTask.recurrenceType!,
        //     ),
        //   );
        // }

        // Update the task in the list and persist changes
        allTasks[index] = updatedTask;
        await updateTaskUseCase(updatedTask);
        await scheduleNotificationByTask(updatedTask);

        // Update the task lists and emit state
        _updateTaskLists(emit);
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
      allTasks = await getTaskUseCase.call();

      // Update the state with the new list of tasks
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState('Failed to bulk update tasks: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await deleteTaskUseCase.call(event.id);
      allTasks.removeWhere((task) => task.id == event.id);
      await flutterLocalNotificationsPlugin.cancel(event.id);
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState('Failed to delete task: $e'));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      await deleteAllTasksUseCase.call();
      allTasks.clear();
      await flutterLocalNotificationsPlugin.cancelAll();
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState('Failed to delete all tasks: $e'));
    }
  }

  List<Task> _applyFilter(Filter filter) {
    switch (filter.filterType) {
      case FilterType.date:
        return _sortTasksByDate(allTasks);
      case FilterType.dueToday:
        return _filterDueToday();
      case FilterType.nodate:
        return _filterByNoDate();
      case FilterType.urgency:
        return _filterUrgent();
      case FilterType.uncomplete:
        return _filterUncompleted();
      case FilterType.completed:
        return _filterCompleted();
      case FilterType.overdue:
        return _filterOverdue();
      case FilterType.category:
        return _filterByCategory(filter.filteredCategory!);
      default:
        return _sortTasksByPriorityAndDate(allTasks);
    }
  }

  List<Task> _filterDueToday() =>
      allTasks.where((task) => isToday(task.date) && !task.isDone).toList();
  List<Task> _filterUrgent() => allTasks
      .where((task) => task.urgencyLevel == TaskPriority.high && !task.isDone)
      .toList();

  List<Task> _filterUncompleted() {
    List<Task> uncompletedTasks =
        allTasks.where((task) => !task.isDone).toList();

    uncompletedTasks.sort((a, b) {
      if (a.urgencyLevel == null && b.urgencyLevel != null) return 1;
      if (a.urgencyLevel != null && b.urgencyLevel == null) return -1;
      if (a.urgencyLevel != null && b.urgencyLevel != null) {
        int priorityComparison =
            b.urgencyLevel!.index.compareTo(a.urgencyLevel!.index);
        if (priorityComparison != 0) return priorityComparison;
      }
      if (a.date == null && b.date != null) return 1;
      if (a.date != null && b.date == null) return -1;
      if (a.date != null && b.date != null) {
        return a.date!.compareTo(b.date!);
      }
      return 0;
    });

    return uncompletedTasks;
  }

  List<Task> _filterCompleted() =>
      allTasks.where((task) => task.isDone).toList();
  List<Task> _filterOverdue() => allTasks
      .where((task) => isOverdue(task.date) && task.isDone == false)
      .toList();
  List<Task> _filterByCategory(TaskCategory category) => allTasks
      .where((task) => task.taskCategory?.id == category.id && !task.isDone)
      .toList();
  List<Task> _filterByNoDate() =>
      allTasks.where((task) => task.date == null && !task.isDone).toList();

  List<Task> _sortTasksByDate(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks.where((task) => !task.isDone).toList();
  }

  List<Task> _sortTasksByPriorityAndDate(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.urgencyLevel == null && b.urgencyLevel != null) return 1;
      if (a.urgencyLevel != null && b.urgencyLevel == null) return -1;
      if (a.urgencyLevel != null && b.urgencyLevel != null) {
        int priorityComparison =
            b.urgencyLevel!.index.compareTo(a.urgencyLevel!.index);
        if (priorityComparison != 0) return priorityComparison;
      }
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks.where((task) => !task.isDone).toList();
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
