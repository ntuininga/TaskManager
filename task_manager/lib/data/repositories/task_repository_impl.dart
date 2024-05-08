import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepositoryImpl(this._appDatabase);

  @override
  Future<List<Task>> getAllTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getAllTasks();
    
    final tasks = taskEntities.map((taskEntity) {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }

  @override
  Future<void> addTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    await taskSource.addTask(taskEntity);
  }

  @override
  Future<void> deleteAllTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    
    await taskSource.deleteAllTasks();
  }


  //Task Category
  @override
  Future<List<TaskCategory>> getAllCategories() async {
    final taskSource = await _appDatabase.taskDatasource;
    final categoryEntities = await taskSource.getAllCategories();

    final categories = categoryEntities.map((entity) {
      return TaskCategory.fromTaskCategoryEntity(entity);
    }).toList();

    return categories;
  }

  @override
  Future<void> addTaskCategory(TaskCategory category) async {
    final taskSource = await _appDatabase.taskDatasource;

    final categoryEntity = TaskCategory.toTaskCategoryEntity(category);
    await taskSource.addTaskCategory(categoryEntity);
  }
}