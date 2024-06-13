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
    
    final tasks = taskEntities.map((taskEntity)  {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }

  @override
  Future<List<Task>> getUnfinishedTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getUnfinishedTasks();
    
    final tasks = taskEntities.map((taskEntity)  {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getCompletedTasks();
    
    final tasks = taskEntities.map((taskEntity)  {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }

  @override
  Future<List<Task>> getTasksBetweenDates(DateTime start, DateTime end) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getTasksBetweenDates(start, end);
    
    final tasks = taskEntities.map((taskEntity)  {
      return Task.fromTaskEntity(taskEntity);
    }).toList();

    return tasks;
  }

  @override
  Future<Task> addTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    final insertedTaskEntity = await taskSource.addTask(taskEntity);

    final insertedTask = Task.fromTaskEntity(insertedTaskEntity);

    return insertedTask;
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    await taskSource.updateTask(taskEntity);
  }

  @override
  Future<void> completeTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final userSource = await _appDatabase.userDatasource;
    final taskEntity = Task.toTaskEntity(task);

    await taskSource.completeTask(taskEntity);
    
    await userSource.completeTask();
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

  @override
  Future<TaskCategory> getCategoryById(int id) async {
    final taskSource = await _appDatabase.taskDatasource;
    final category = await TaskCategory.fromTaskCategoryEntity(await taskSource.getCategoryById(id));

    return category;
  }
}