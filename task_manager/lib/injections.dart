import 'package:get_it/get_it.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/data/repositories/user_repository_impl.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/domain/usecases/add_task.dart';
import 'package:task_manager/domain/usecases/get_tasks.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));

  sl.registerFactory(() => TasksBloc(getTaskUseCase: sl(), addTaskUseCase: sl()));
}