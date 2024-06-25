import 'package:get_it/get_it.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/data/repositories/user_repository_impl.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/tasks/add_task.dart';
import 'package:task_manager/domain/usecases/tasks/delete_task.dart';
import 'package:task_manager/domain/usecases/tasks/get_tasks.dart';
import 'package:task_manager/domain/usecases/tasks/update_task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetTaskUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));

  sl.registerLazySingleton(() => GetTaskCategoriesUseCase(sl()));

  sl.registerFactory(() => TasksBloc(
    getTaskUseCase: sl(),
    addTaskUseCase: sl(),
    updateTaskUseCase: sl(),
    deleteTaskUseCase: sl())
    );

  sl.registerFactory(() => TaskCategoriesBloc(
    getTaskCategoriesUseCase: sl())
    );

  Future<void> _initializeDefaultCategories(TaskRepository repository) async {
    final categories = await repository.getAllCategories();

    if (categories.isEmpty) {
      await repository.addTaskCategory(TaskCategory(title: 'Personal'));
      await repository.addTaskCategory(TaskCategory(title: 'Work'));
      await repository.addTaskCategory(TaskCategory(title: 'Shopping'));
    }
  }
}
