// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:task_manager/core/filter.dart';
// import 'package:task_manager/core/notifications/notification_repository.dart';
// import 'package:task_manager/core/notifications/notifications_utils.dart';
// import 'package:task_manager/data/entities/task_entity.dart';
// import 'package:task_manager/domain/models/task.dart';
// import 'package:task_manager/domain/models/task_category.dart';
// import 'package:task_manager/domain/usecases/tasks/add_task.dart';
// import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
// import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
// import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
// import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
// import 'package:task_manager/domain/usecases/tasks/update_task.dart';

// part 'tasks_event.dart';
// part 'tasks_state.dart';

// class TasksBloc extends Bloc<TasksEvent, TasksState> {
//   final GetTaskUseCase getTaskUseCase;
//   final GetTaskByIdUseCase getTaskByIdUseCase;
//   final AddTaskUseCase addTaskUseCase;
//   final UpdateTaskUseCase updateTaskUseCase;
//   final DeleteTaskUseCase deleteTaskUseCase;
//   final DeleteAllTasksUseCase deleteAllTasksUseCase;

//   List<Task> displayedTasks = [];
//   List<Task> filteredTasks = [];
//   Filter? currentFilter;

//   TasksBloc({
//     required this.getTaskUseCase,
//     required this.getTaskByIdUseCase,
//     required this.addTaskUseCase,
//     required this.updateTaskUseCase,
//     required this.deleteTaskUseCase,
//     required this.deleteAllTasksUseCase,
//   }) : super(LoadingGetTasksState()) {
//     on<FilterTasks>(_onFilterTasksEvent);
//     on<OnGettingTasksEvent>(_onGettingTasksEvent);
//     on<AddTask>(_onAddTask);
//     on<UpdateTask>(_onUpdateTask);
//     on<DeleteTask>(_onDeleteTask);
//     on<DeleteAllTasks>(_onDeleteAllTasks);
//   }

//   Future<void> _refreshTasks(Emitter<TasksState> emitter) async {
//     try {
//       final result = await getTaskUseCase.call();
//       displayedTasks = sortTasksByPriorityAndDate(result);

//       filteredTasks = displayedTasks.where((task) => !task.isDone).toList();
//       final completedTasks = displayedTasks.where((task) => task.isDone).toList();
//       final todaysTasks = _getTodaysTasks(displayedTasks);

//       emitter(SuccessGetTasksState(
//         List.from(displayedTasks),
//         List.from(filteredTasks),
//         List.from(filteredTasks),
//         List.from(todaysTasks),
//         currentFilter,
//       ));
//     } catch (e) {
//       print('Error in _refreshTasks: $e');
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onGettingTasksEvent(
//       OnGettingTasksEvent event, Emitter<TasksState> emitter) async {
//     try {
//       if (event.withLoading) {
//         emitter(LoadingGetTasksState());
//       }
//       await _refreshTasks(emitter);

//       // After loading tasks, apply the default filter (e.g., uncompleted tasks).
//       add(const FilterTasks(filter: FilterType.uncomplete));
//     } catch (e) {
//       print('Error in _onGettingTasksEvent: $e');
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onFilterTasksEvent(
//       FilterTasks event, Emitter<TasksState> emitter) async {
//     try {
//       final currentState = state;
//       final result = await getTaskUseCase.call();
//       displayedTasks = sortTasksByPriorityAndDate(result);

//       final uncompleteTasks =
//           displayedTasks.where((task) => !task.isDone).toList();
//       if (currentState is SuccessGetTasksState) {
//         currentFilter = Filter(event.filter, event.category);
//         filteredTasks = _applyFilter(event, uncompleteTasks, result);

//         emitter(SuccessGetTasksState(
//           List.from(currentState.allTasks),
//           List.from(currentState.uncompleteTasks),
//           List.from(filteredTasks),
//           List.from(currentState.dueTodayTasks),
//           currentFilter,
//         ));
//       }
//     } catch (e) {
//       print('Error in _onFilterTasksEvent: $e');
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onAddTask(AddTask event, Emitter<TasksState> emitter) async {
//     try {
//       // Create the new task with default values for urgency and notification
//       print("bloc: ${event.taskToAdd.notifyBeforeMinutes}");
//       Task newTask = await addTaskUseCase.call(event.taskToAdd.copyWith(
//         urgencyLevel: event.taskToAdd.urgencyLevel ?? TaskPriority.none,
//       ));

//       // If reminder fields are set, schedule the notification
//       if (newTask.date != null &&
//           newTask.time != null &&
//           newTask.notifyBeforeMinutes != null) {
//         final scheduledDateTime = DateTime(
//           newTask.date!.year,
//           newTask.date!.month,
//           newTask.date!.day,
//           newTask.time!.hour,
//           newTask.time!.minute,
//         ).subtract(Duration(minutes: newTask.notifyBeforeMinutes!));

//         // Check if the scheduled time is in the future
//         if (scheduledDateTime.isAfter(DateTime.now())) {
//           // Update task with reminder flag set to true
//           final updatedTask = newTask.copyWith(reminder: true);
//           await scheduleNotificationByDateAndTime(
//               updatedTask, updatedTask.date!, updatedTask.time!);
//           newTask = updatedTask; // Ensure the task has the reminder flag
//         } else {
//           print("Cannot schedule a notification in the past.");
//         }
//       }

//       // Add the new task to the displayed tasks list
//       displayedTasks.insert(0, newTask);

//       // Apply the current filter to check if the new task should be displayed
//       if (_taskMatchesCurrentFilter(newTask)) {
//         filteredTasks.insert(0, newTask);
//       }

//       // Emit the updated task state
//       emitter(SuccessGetTasksState(
//         List.from(displayedTasks),
//         List.from(displayedTasks
//             .where((task) => !task.isDone)
//             .toList()), // Uncompleted tasks
//         List.from(filteredTasks),
//         List.from(_getTodaysTasks(displayedTasks)), // Tasks due today
//         currentFilter,
//       ));
//     } catch (e) {
//       print('Error in _onAddTask: $e');
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onUpdateTask(
//       UpdateTask event, Emitter<TasksState> emitter) async {
//     try {
//       if (event.taskToUpdate.id == null) {
//         emitter(const ErrorState("Task ID cannot be null"));
//         return;
//       }

//       final taskFromRepo =
//           await getTaskByIdUseCase.call(event.taskToUpdate.id!);
//       if (taskFromRepo == null) {
//         emitter(const ErrorState("Task not found in the repository"));
//         return;
//       }

//       final isCompletionStateChanging =
//           taskFromRepo.isDone != event.taskToUpdate.isDone;
//       var updatedTask = event.taskToUpdate;

//       if (isCompletionStateChanging) {
//         updatedTask = updatedTask.copyWith(
//           isDone: !taskFromRepo.isDone,
//           completedDate: event.taskToUpdate.isDone ? DateTime.now() : null,
//         );
//       }

//       await updateTaskUseCase.call(updatedTask);

//       // Manage notifications
//       await flutterLocalNotificationsPlugin.cancel(updatedTask.id!);
//       if (updatedTask.date != null &&
//           updatedTask.time != null &&
//           updatedTask.notifyBeforeMinutes != null) {
//         final scheduledDateTime = DateTime(
//           updatedTask.date!.year,
//           updatedTask.date!.month,
//           updatedTask.date!.day,
//           updatedTask.time!.hour,
//           updatedTask.time!.minute,
//         ).subtract(Duration(minutes: updatedTask.notifyBeforeMinutes!));

//         if (scheduledDateTime.isAfter(DateTime.now())) {
//           await scheduleNotificationByDateAndTime(
//               updatedTask, updatedTask.date!, updatedTask.time!);
//         } else {
//           print("Cannot schedule a notification in the past.");
//         }
//       }

//       // Update task lists based on filter
//       if (!_taskMatchesCurrentFilter(updatedTask)) {
//         displayedTasks.removeWhere((task) => task.id == updatedTask.id);
//         filteredTasks.removeWhere((task) => task.id == updatedTask.id);
//       } else {
//         displayedTasks = displayedTasks
//             .map((task) => task.id == updatedTask.id ? updatedTask : task)
//             .toList();
//         filteredTasks = filteredTasks
//             .map((task) => task.id == updatedTask.id ? updatedTask : task)
//             .toList();
//       }

//       emitter(SuccessGetTasksState(
//         List.from(displayedTasks),
//         displayedTasks.where((task) => !task.isDone).toList(),
//         List.from(filteredTasks),
//         _getTodaysTasks(displayedTasks),
//         currentFilter,
//       ));
//     } catch (e) {
//       print('Error in _onUpdateTask: $e');
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onDeleteTask(
//       DeleteTask event, Emitter<TasksState> emitter) async {
//     try {
//       await deleteTaskUseCase.call(event.id);
//       await flutterLocalNotificationsPlugin.cancel(event.id);

//       displayedTasks.removeWhere((task) => task.id == event.id);
//       filteredTasks.removeWhere((task) => task.id == event.id);

//       emitter(SuccessGetTasksState(
//         List.from(displayedTasks),
//         List.from(displayedTasks.where((task) => !task.isDone).toList()),
//         List.from(filteredTasks),
//         List.from(_getTodaysTasks(displayedTasks)),
//         currentFilter,
//       ));
//     } catch (e) {
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   Future<void> _onDeleteAllTasks(
//       DeleteAllTasks event, Emitter<TasksState> emitter) async {
//     try {
//       await deleteAllTasksUseCase.call();
//       await flutterLocalNotificationsPlugin.cancelAll();

//       displayedTasks.clear();
//       filteredTasks.clear();

//       emitter(SuccessGetTasksState(
//         List.from(displayedTasks),
//         List.from(displayedTasks.where((task) => !task.isDone).toList()),
//         List.from(filteredTasks),
//         List.from(_getTodaysTasks(displayedTasks)),
//         currentFilter,
//       ));
//     } catch (e) {
//       emitter(ErrorState(e.toString()));
//     }
//   }

//   List<Task> sortTasksByDate(List<Task> tasks) {
//     tasks.sort((a, b) {
//       if (a.date == null && b.date == null) return 0;
//       if (a.date == null) return 1;
//       if (b.date == null) return -1;
//       return a.date!.compareTo(b.date!);
//     });
//     return tasks;
//   }

//   List<Task> sortTasksByPriorityAndDate(List<Task> tasks) {
//     tasks.sort((a, b) {
//       int priorityComparison = _priorityValue(a.urgencyLevel)
//           .compareTo(_priorityValue(b.urgencyLevel));
//       if (priorityComparison != 0) {
//         return priorityComparison;
//       }

//       if (a.date == null && b.date == null) return 0;
//       if (a.date == null) return 1;
//       if (b.date == null) return -1;
//       return a.date!.compareTo(b.date!);
//     });
//     return tasks;
//   }

//   List<Task> _applyFilter(
//       FilterTasks event, List<Task> uncompleteTasks, List<Task> allTasks) {
//     List<Task> filteredTasks = uncompleteTasks;

//     switch (event.filter) {
//       case FilterType.all:
//         // No filter applied, show all tasks
//         break;

//       case FilterType.uncomplete:
//         filteredTasks = filteredTasks.where((task) => !task.isDone).toList();
//         break;

//       case FilterType.completed:
//         filteredTasks = allTasks.where((task) => task.isDone).toList();
//         break;

//       case FilterType.pending:
//         filteredTasks = filteredTasks
//             .where((task) =>
//                 !task.isDone &&
//                 task.date != null &&
//                 task.date!.isAfter(DateTime.now()))
//             .toList();
//         break;

//       case FilterType.urgency:
//         filteredTasks = filteredTasks
//             .where((task) => task.urgencyLevel == TaskPriority.high)
//             .toList();
//         break;

//       case FilterType.dueToday:
//         filteredTasks = filteredTasks.where((task) {
//           if (task.date != null) {
//             final today = DateTime.now();
//             return task.date!.year == today.year &&
//                 task.date!.month == today.month &&
//                 task.date!.day == today.day;
//           }
//           return false;
//         }).toList();
//         break;

//       case FilterType.date:
//         filteredTasks.sort((a, b) {
//           if (a.date == null && b.date == null) return 0;
//           if (a.date == null) return 1;
//           if (b.date == null) return -1;
//           return a.date!.compareTo(b.date!);
//         });
//         break;

//       case FilterType.category:
//         if (event.category != null) {
//           filteredTasks = filteredTasks
//               .where((task) => task.taskCategory!.id == event.category!.id)
//               .toList();
//         }
//         break;

//       case FilterType.nodate:
//         filteredTasks =
//             filteredTasks.where((task) => task.date == null).toList();
//         break;

//       case FilterType.overdue:
//         filteredTasks = filteredTasks.where((task) {
//           if (task.date != null) {
//             return task.date!.isBefore(DateTime.now()) && !task.isDone;
//           }
//           return false;
//         }).toList();
//         break;
//     }

//     return filteredTasks;
//   }

//   bool _taskMatchesCurrentFilter(Task task) {
//     FilterType? filterType = currentFilter?.filterType;

//     // Check if filter is based on category
//     if (filterType == FilterType.category) {
//       if (task.taskCategory?.id != null &&
//           currentFilter?.filteredCategory?.id != null) {
//         return task.taskCategory!.id == currentFilter?.filteredCategory!.id;
//       } else {
//         return false; // Task doesn't match the filtered category
//       }
//     }

//     // Check if filter is based on completed tasks
//     if (filterType == FilterType.completed) {
//       return task.isDone == true;
//     }

//     // Check if filter is based on uncompleted tasks
//     if (filterType == FilterType.uncomplete) {
//       return task.isDone == false;
//     }

//     // Check if filter is due today
//     if (filterType == FilterType.dueToday) {
//       final today = DateTime.now();
//       return task.date != null &&
//           task.date!.year == today.year &&
//           task.date!.month == today.month &&
//           task.date!.day == today.day;
//     }

//     // Check if filter is overdue tasks
//     if (filterType == FilterType.overdue) {
//       return task.date != null &&
//           task.date!.isBefore(DateTime.now()) &&
//           !task.isDone;
//     }

//     if (filterType == FilterType.urgency) {
//       return task.urgencyLevel == TaskPriority.high;
//     }

//     if (filterType == FilterType.nodate) {
//       return task.date == null;
//     }

//     // Add more filters as needed (e.g., FilterType.pending, urgency, etc.)

//     return true; // Default to including the task if no specific filter applies
//   }

//   List<Task> _getTodaysTasks(List<Task> tasks) {
//     DateTime today = DateTime.now();
//     return tasks
//         .where((task) =>
//             task.date != null &&
//             task.date!.year == today.year &&
//             task.date!.month == today.month &&
//             task.date!.day == today.day)
//         .toList();
//   }

//   Future<List<Task>> _getAllCompletedTasks() {
//     return getTaskUseCase.call();
//   }

//   int _priorityValue(TaskPriority? priority) {
//     switch (priority) {
//       case TaskPriority.high:
//         return 0;
//       case TaskPriority.none:
//         return 1;
//       default:
//         return 3;
//     }
//   }
// }