import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/datasources/local/dao/recurrence_dao.dart';
import 'package:task_manager/data/datasources/local/dao/task_dao.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _taskDatasource;
  final RecurrenceDao _recurrenceDao;

  TaskRepositoryImpl(this._taskDatasource, this._recurrenceDao);

  Future<Task> getTaskFromEntity(TaskEntity entity) async {
    TaskCategory? category;
    RecurrenceRuleset? recurrenceRuleset;
    Task task = Task.fromTaskEntity(entity);

    if (entity.taskCategoryId != null) {
      try {
        final categoryEntity =
            await _taskDatasource.getCategoryById(entity.taskCategoryId!);
        category = TaskCategory.fromTaskCategoryEntity(categoryEntity);
      } catch (e) {
        throw Exception(
            'Failed to get Category with Id ${entity.taskCategoryId}: $e');
      }
    }

    if (entity.recurrenceRuleId != null) {
      try {
        final recurrenceEntity = await _recurrenceDao
            .getRecurrenceRuleById(entity.recurrenceRuleId!);
        if (recurrenceEntity != null) {
          recurrenceRuleset = RecurrenceRuleset.fromEntity(recurrenceEntity);
        }
      } catch (e) {
        throw Exception(
            'Failed to get Recurrence Ruleset with Id ${entity.recurrenceRuleId}: $e');
      }
    }

    return task.copyWith(
      taskCategory: category,
      recurrenceRuleset: recurrenceRuleset,
    );
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final taskEntities = await _taskDatasource.getAllTasks();
    return Future.wait(taskEntities.map(getTaskFromEntity));
  }

  @override
  Future<List<Task>> getUncompletedNonRecurringTasks() async {
    final taskEntities =
        await _taskDatasource.getUncompletedNonRecurringTasks();
    return Future.wait(taskEntities.map(getTaskFromEntity));
  }

  @override
  Future<Task> getTaskById(int id) async {
    try {
      final taskEntity = await _taskDatasource.getTaskById(id);
      return getTaskFromEntity(taskEntity);
    } catch (e) {
      throw Exception('Failed to get task with id $id: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByCategory(int categoryId) async {
    try {
      final taskEntities = await _taskDatasource.getTasksByCategory(categoryId);
      return Future.wait(taskEntities.map(getTaskFromEntity));
    } catch (e) {
      throw Exception('Failed to get tasks with category id $categoryId: $e');
    }
  }

  @override
  Future<List<Task>> getUnfinishedTasks() async {
    final taskEntities = await _taskDatasource.getUnfinishedTasks();
    return Future.wait(taskEntities.map(getTaskFromEntity));
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final taskEntities = await _taskDatasource.getCompletedTasks();
    return Future.wait(taskEntities.map(getTaskFromEntity));
  }

  @override
  Future<List<Task>> getTasksBetweenDates(DateTime start, DateTime end) async {
    final taskEntities = await _taskDatasource.getTasksBetweenDates(start, end);
    return Future.wait(taskEntities.map(getTaskFromEntity));
  }

  @override
  Future<Task> addTask(Task task) async {
    final taskEntity = await Task.toTaskEntity(task);
    try {
      final insertedEntity = await _taskDatasource.addTask(taskEntity);
      return getTaskFromEntity(insertedEntity);
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    final taskEntity = await Task.toTaskEntity(task);
    try {
      final updatedEntity = await _taskDatasource.updateTask(taskEntity);
      return getTaskFromEntity(updatedEntity);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> bulkUpdateTasks(
      List<int> taskIds, TaskCategory? newCategory, bool? markComplete) async {
    final updateMap = <String, dynamic>{};
    if (newCategory != null) updateMap[taskCategoryIdField] = newCategory.id;
    if (markComplete != null) updateMap[isDoneField] = markComplete ? 1 : 0;

    try {
      for (var id in taskIds) {
        await _taskDatasource.updateTaskFields(id, updateMap);
      }
    } catch (e) {
      throw Exception('Failed to bulk update tasks: $e');
    }
  }

  @override
  Future<void> completeTask(Task task) async {
    final taskEntity = await Task.toTaskEntity(task);
    try {
      await _taskDatasource.completeTask(taskEntity);
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  @override
  Future<void> deleteAllTasks() async {
    try {
      await _taskDatasource.deleteAllTasks();
    } catch (e) {
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  @override
  Future<void> deleteTaskById(int id) async {
    try {
      await _taskDatasource.deleteTaskById(id);
    } catch (e) {
      throw Exception('Failed to delete task with id $id: $e');
    }
  }

  @override
  Future<void> deleteTasksWithCategory(int categoryId) async {
    try {
      await _taskDatasource.deleteTasksWithCategory(categoryId);
    } catch (e) {
      throw Exception(
          'Failed to delete tasks with category Id $categoryId: $e');
    }
  }

  @override
  Future<void> removeCategoryFromTasks(int categoryId) async {
    try {
      await _taskDatasource.removeCategoryFromTasks(categoryId);
    } catch (e) {
      throw Exception(
          'Failed to remove Category with Id $categoryId from tasks');
    }
  }

  @override
  Future<List<TaskCategory>> getAllCategories() async {
    final entities = await _taskDatasource.getAllCategories();
    return entities.map(TaskCategory.fromTaskCategoryEntity).toList();
  }

  @override
  Future<void> addTaskCategory(TaskCategory category) async {
    final entity = category.toTaskCategoryEntity();
    try {
      await _taskDatasource.addTaskCategory(entity);
    } catch (e) {
      throw Exception('Failed to add task category: $e');
    }
  }

  @override
  Future<TaskCategory> updateTaskCategory(TaskCategory category) async {
    final entity = category.toTaskCategoryEntity();
    try {
      final updated = await _taskDatasource.updateTaskCategory(entity);
      return TaskCategory.fromTaskCategoryEntity(updated);
    } catch (e) {
      throw Exception('Failed to update task category: $e');
    }
  }

  @override
  Future<void> deleteTaskCategory(int id) async {
    try {
      await _taskDatasource.deleteTaskCategory(id);
    } catch (e) {
      throw Exception('Failed to delete task category with id $id: $e');
    }
  }

  @override
  Future<TaskCategory> getCategoryById(int id) async {
    try {
      final entity = await _taskDatasource.getCategoryById(id);
      return TaskCategory.fromTaskCategoryEntity(entity);
    } catch (e) {
      throw Exception('Failed to get category with id $id: $e');
    }
  }
}
