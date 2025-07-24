import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/datasources/local/dao/recurrence_dao.dart';
import 'package:task_manager/data/datasources/local/dao/recurring_instance_dao.dart';
import 'package:task_manager/data/datasources/local/dao/recurring_task_dao.dart';
import 'package:task_manager/data/datasources/local/dao/task_dao.dart';
import 'package:task_manager/data/repositories/recurrence_rules_repository_impl.dart';
import 'package:task_manager/data/repositories/recurring_details_repository_impl.dart';
import 'package:task_manager/data/repositories/recurring_instance_repository_impl.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/data/repositories/user_repository_impl.dart';
import 'package:task_manager/domain/repositories/recurrence_rules_repository.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';
import 'package:task_manager/domain/repositories/recurring_instance_repository.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/domain/usecases/add_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/clear_all_scheduled_dates_usecase.dart';
import 'package:task_manager/domain/usecases/get_recurrence_details_usecase.dart';
import 'package:task_manager/domain/usecases/recurring_task_details/add_completed_date_usecase.dart';
import 'package:task_manager/domain/usecases/recurring_task_details/remove_scheduled_date_usecase.dart';
import 'package:task_manager/domain/usecases/task_categories/add_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/task_categories/update_task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/bulk_update.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks_by_category.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:task_manager/domain/usecases/update_existing_recurring_dates_usecase.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  Database db = await sl<AppDatabase>().database;

  //Register DAO
  sl.registerLazySingleton<RecurringTaskDao>(() => RecurringTaskDao(db));
  sl.registerLazySingleton<TaskDatasource>(() => TaskDatasource(db));
  sl.registerLazySingleton<RecurringInstanceDao>(
      () => RecurringInstanceDao(db));
  sl.registerLazySingleton<RecurrenceDao>(() => RecurrenceDao(db));

  //Register Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(
        sl<TaskDatasource>(),
        sl<RecurrenceDao>(),
      ));

  sl.registerLazySingleton<RecurringInstanceRepository>(
      () => RecurringInstanceRepositoryImpl(sl()));
  sl.registerLazySingleton<RecurrenceRulesRepository>(
      () => RecurrenceRulesRepositoryImpl(sl()));
  sl.registerLazySingleton<RecurringTaskRepository>(
      () => RecurringTaskRepositoryImpl(sl()));

  // Register Use Cases for Tasks
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
  sl.registerLazySingleton(() => AddCompletedDateUseCase(sl()));
  sl.registerLazySingleton(() => RemoveScheduledDateUseCase(sl()));

  // Register Blocs
  sl.registerFactory(() => TasksBloc(
      taskRepository: sl(),
      recurringInstanceRepository: sl(),
      recurringRulesRepository: sl(),
      recurringTaskRepository: sl(),
      getTaskByIdUseCase: sl(),
      getTasksByCategoryUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      deleteAllTasksUseCase: sl(),
      deleteTaskCategoryUseCase: sl(),
      bulkUpdateTasksUseCase: sl(),
      addScheduledDatesUseCase: sl()));

  sl.registerFactory(() => SettingsBloc());

  sl.registerFactory(() => TaskCategoriesBloc(
        tasksBloc: sl(),
        getTaskCategoriesUseCase: sl(),
        addTaskCategoryUseCase: sl(),
        updateTaskCategoryUseCase: sl(),
        deleteTaskCategoryUseCase: sl(),
      ));
}
