import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/datasources/local/recurring_task_dao.dart';
import 'package:task_manager/data/repositories/recurring_details_repository_impl.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/data/repositories/user_repository_impl.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/domain/usecases/add_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/clear_all_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/get_recurrence_details_usecase.dart';
import 'package:task_manager/domain/usecases/task_categories/add_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/task_categories/update_task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/bulk_update.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks_by_category.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:task_manager/domain/usecases/update_existing_recurring_dates_usecase.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/recurring_details/recurring_details_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  Database db = await sl<AppDatabase>().database;
  sl.registerLazySingleton<RecurringTaskDao>(() => RecurringTaskDao(db));

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton<RecurringTaskRepository>(
      () => RecurringTaskRepositoryImpl(sl()));

  // Register Use Cases for Tasks
  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTaskByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAllTasksUseCase(sl()));

  // Register Use Cases for Task Categories
  sl.registerLazySingleton(() => GetTaskCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskCategoryUseCase(sl()));
  sl.registerLazySingleton(() => BulkUpdateTasksUseCase(sl()));

  sl.registerLazySingleton(() => AddScheduledDatesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecurrenceDetailsUsecase(sl()));
  sl.registerLazySingleton(() => ClearScheduledDatesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateScheduledDatesUseCase(sl()));

  // Register Blocs
  sl.registerFactory(() => TasksBloc(
      getTaskUseCase: sl(),
      getTaskByIdUseCase: sl(),
      getTasksByCategoryUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      deleteAllTasksUseCase: sl(),
      deleteTaskCategoryUseCase: sl(),
      bulkUpdateTasksUseCase: sl(),
      addScheduledDatesUseCase: sl()));

  sl.registerFactory(() => TaskCategoriesBloc(
        tasksBloc: sl(),
        getTaskCategoriesUseCase: sl(),
        addTaskCategoryUseCase: sl(),
        updateTaskCategoryUseCase: sl(),
        deleteTaskCategoryUseCase: sl(),
      ));

  sl.registerFactory(() => RecurringDetailsBloc(
        getRecurrenceDetailsUsecase: sl(),
        addScheduledDatesUseCase: sl(),
        clearScheduledDatesUseCase: sl(),
        updateScheduledDatesUseCase: sl(),
      ));
}
