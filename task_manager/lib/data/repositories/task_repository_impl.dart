import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepositoryImpl(this._appDatabase);

  Future<Task> getTaskFromEntity(TaskEntity entity) async {
    final taskSource = await _appDatabase.taskDatasource;
    TaskCategory? category;

    if (entity.taskCategoryId != null) {
      try {
        var categoryEntity =
            await taskSource.getCategoryById(entity.taskCategoryId!);
        category = TaskCategory.fromTaskCategoryEntity(categoryEntity);
      } catch (e) {
        // Handle potential errors when fetching category
        print('Error fetching category: $e');
      }
    }

    Task task = await Task.fromTaskEntity(entity);

    return task.copyWith(taskCategory: category);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getAllTasks();

    final tasks = await Future.wait(taskEntities.map((taskEntity) async {
      return await getTaskFromEntity(taskEntity);
    }).toList());

    return tasks;
  }

  @override
  Future<Task> getTaskById(int id) async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      final taskEntity = await taskSource.getTaskById(id);
      return Task.fromTaskEntity(taskEntity);
    } catch (e) {
      throw Exception('Failed to get task with id $id: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByCategory(int categoryId) async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      final taskEntities = await taskSource.getTasksByCategory(categoryId);
      final tasks = await Future.wait(taskEntities.map((taskEntity) async {
        return await getTaskFromEntity(taskEntity);
      }).toList());

      return tasks;
    } catch (e) {
      throw Exception('Failed to get tasks with category id $categoryId: $e');
    }
  }

  @override
  Future<List<Task>> getUnfinishedTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getUnfinishedTasks();

    final tasks = await Future.wait(taskEntities.map((taskEntity) async {
      return await getTaskFromEntity(taskEntity);
    }).toList());

    return tasks;
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getCompletedTasks();

    final tasks = await Future.wait(taskEntities.map((taskEntity) async {
      return await getTaskFromEntity(taskEntity);
    }).toList());

    return tasks;
  }

  @override
  Future<List<Task>> getTasksBetweenDates(DateTime start, DateTime end) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntities = await taskSource.getTasksBetweenDates(start, end);

    final tasks = await Future.wait(taskEntities.map((taskEntity) async {
      return await getTaskFromEntity(taskEntity);
    }).toList());

    return tasks;
  }

  @override
  Future<Task> addTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    try {
      final insertedTaskEntity = await taskSource.addTask(taskEntity);
      return await getTaskFromEntity(insertedTaskEntity);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    try {
      final updatedEntity = await taskSource.updateTask(taskEntity);
      return await getTaskFromEntity(updatedEntity);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> completeTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = Task.toTaskEntity(task);

    try {
      await taskSource.completeTask(taskEntity);
      // Optionally update user or perform other tasks after completing task
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to complete task: $e');
    }
  }

  @override
  Future<void> deleteAllTasks() async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      await taskSource.deleteAllTasks();
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  @override
  Future<void> deleteTaskById(int id) async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      await taskSource.deleteTaskById(id);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to delete task with id $id: $e');
    }
  }

  // Task Category
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
    final categoryEntity = category.toTaskCategoryEntity();

    try {
      await taskSource.addTaskCategory(categoryEntity);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to add task category: $e');
    }
  }

  @override
  Future<TaskCategory> updateTaskCategory(TaskCategory category) async {
    final taskSource = await _appDatabase.taskDatasource;
    final categoryEntity = category.toTaskCategoryEntity();

    try {
      final updatedEntity = await taskSource.updateTaskCategory(categoryEntity);
      return TaskCategory.fromTaskCategoryEntity(updatedEntity);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to update task category: $e');
    }
  }

  @override
  Future<void> deleteTaskCategory(int id) async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      await taskSource.deleteTaskCategory(id);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to delete task category with id $id: $e');
    }
  }

  @override
  Future<TaskCategory> getCategoryById(int id) async {
    final taskSource = await _appDatabase.taskDatasource;

    try {
      final categoryEntity = await taskSource.getCategoryById(id);
      return TaskCategory.fromTaskCategoryEntity(categoryEntity);
    } catch (e) {
      // Handle database errors or null category
      throw Exception('Failed to get category with id $id: $e');
    }
  }
}
