import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/filter.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTaskUseCase getTaskUseCase;
  final GetTaskByIdUseCase getTaskByIdUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final DeleteAllTasksUseCase deleteAllTasksUseCase;

  List<Task> allTasks = [];
  List<Task> displayedTasks = [];
  List<Task> filteredTasks = [];
  Filter? currentFilter;

  TasksBloc({
    required this.getTaskUseCase,
    required this.getTaskByIdUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.deleteAllTasksUseCase,
  }) : super(LoadingGetTasksState()) {
    on<FilterTasks>(_onFilterTasksEvent);
    on<OnGettingTasksEvent>(_onGettingTasksEvent);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<DeleteAllTasks>(_onDeleteAllTasks);
  }

  void _updateTaskLists(Emitter<TasksState> emit) {
    emit(SuccessGetTasksState(
        allTasks: allTasks,
        dueTodayTasks: _filterDueToday(),
        urgentTasks: _filterUrgent(),
        uncompleteTasks: _filterUncompleted(),
        completeTasks: _filterCompleted(),
        filteredTasks: _applyFilter(currentFilter!),
        activeFilter: currentFilter,
        todayCount: _filterDueToday().where((task) => !task.isDone).length,
        urgentCount: _filterUrgent().where((task) => !task.isDone).length,
        overdueCount: _filterOverdue().where((task) => !task.isDone).length));
  }

  Future<void> _onGettingTasksEvent(
      OnGettingTasksEvent event, Emitter<TasksState> emit) async {
    try {
      if (event.withLoading) {
        emit(LoadingGetTasksState());
      }
      allTasks = await getTaskUseCase.call();
      _updateTaskLists(emit);

      add(const FilterTasks(filter: FilterType.uncomplete));
    } catch (e) {
      print('Error in _onGettingTasksEvent: $e');
      emit(ErrorState(e.toString()));
    }
  }

  void _onFilterTasksEvent(FilterTasks event, Emitter<TasksState> emit) {
    currentFilter = Filter(event.filter, event.category);
    emit(SuccessGetTasksState(
      allTasks: allTasks,
      dueTodayTasks: _filterDueToday(),
      urgentTasks: _filterUrgent(),
      uncompleteTasks: _filterUncompleted(),
      completeTasks: _filterCompleted(),
      filteredTasks: _applyFilter(currentFilter!),
      activeFilter: currentFilter,
      todayCount: _filterDueToday().length,
      urgentCount: _filterUrgent().length,
      overdueCount: _filterOverdue().length,
    ));
  }

  List<Task> _applyFilter(Filter filter) {
    currentFilter = filter;

    switch (filter.filterType) {
      case FilterType.date:
        return _sortTasksByDate(allTasks);
      case FilterType.dueToday:
        return _filterDueToday();
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
        return allTasks;
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      Task addedTask = await addTaskUseCase.call(event.taskToAdd);

      allTasks.add(addedTask);
      _updateTaskLists(emit);
      //add(ScheduleTaskReminder(event.task));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _onToggleCompletion(
      ToggleTaskCompletion event, Emitter<TasksState> emit) async {
    try {} catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    try {
      final index =
          allTasks.indexWhere((task) => task.id == event.taskToUpdate.id);
      if (index != -1) {
        allTasks[index] = event.taskToUpdate;

        await updateTaskUseCase(event.taskToUpdate);
        //Schedule a notification if necessary

        _updateTaskLists(emit);
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await deleteTaskUseCase.call(event.id);
      allTasks.removeWhere((task) => task.id == event.id);
      await flutterLocalNotificationsPlugin.cancel(event.id);
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAllTasks(
      DeleteAllTasks event, Emitter<TasksState> emit) async {
    try {
      await deleteAllTasksUseCase.call();
      await flutterLocalNotificationsPlugin.cancelAll();

      allTasks.clear();
      _updateTaskLists(emit);
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  List<Task> _sortTasksByDate(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks;
  }

  List<Task> _sortTasksByPriorityAndDate(List<Task> tasks) {
    tasks.sort((a, b) {
      int priorityComparison = _priorityValue(a.urgencyLevel)
          .compareTo(_priorityValue(b.urgencyLevel));
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    return tasks;
  }

  List<Task> _filterDueToday() =>
      allTasks.where((task) => isToday(task.date)).toList();
  List<Task> _filterUrgent() =>
      allTasks.where((task) => task.urgencyLevel == TaskPriority.high).toList();
  List<Task> _filterUncompleted() =>
      allTasks.where((task) => !task.isDone).toList();
  List<Task> _filterCompleted() =>
      allTasks.where((task) => task.isDone).toList();
  List<Task> _filterOverdue() =>
      allTasks.where((task) => isOverdue(task.date)).toList();
  List<Task> _filterByCategory(TaskCategory category) =>
      allTasks.where((task) => task.taskCategory!.id == category.id).toList();

  int _priorityValue(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.none:
        return 1;
      default:
        return 3;
    }
  }
}
