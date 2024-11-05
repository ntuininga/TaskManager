import 'package:get_it/get_it.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/data/repositories/user_repository_impl.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/domain/usecases/task_categories/add_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/task_categories/update_task_category.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/delete_all_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks_by_category.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

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

  // Register Blocs
  sl.registerFactory(() => TasksBloc(
      getTaskUseCase: sl(),
      getTaskByIdUseCase: sl(),
      addTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      deleteAllTasksUseCase: sl()));

  sl.registerFactory(() => TaskCategoriesBloc(
      getTaskCategoriesUseCase: sl(),
      addTaskCategoryUseCase: sl(),
      updateTaskCategoryUseCase: sl(),
      deleteTaskCategoryUseCase: sl(),
      getTasksByCategoryUseCase: sl(),
      updateTaskUseCase: sl()));
}
