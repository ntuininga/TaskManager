import 'package:flutter/material.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/recurrence_ruleset_entity.dart';
import 'package:task_manager/data/entities/recurring_instance_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _appDatabase;

  TaskRepositoryImpl(this._appDatabase);

  Future<Task> getTaskFromEntity(TaskEntity entity) async {
    final taskSource = await _appDatabase.taskDatasource;
    final recurrenceDao = await _appDatabase.recurrenceDao;
    TaskCategory? category;
    RecurrenceRuleset? recurrenceRuleset;

    Task task = Task.fromTaskEntity(entity);

    if (entity.taskCategoryId != null) {
      try {
        var categoryEntity =
            await taskSource.getCategoryById(entity.taskCategoryId!);
        // If categoryEntity is null (category was deleted), set category to null
        category = TaskCategory.fromTaskCategoryEntity(categoryEntity);
      } catch (e) {
        // Handle any unexpected errors
        throw Exception(
            'Failed to get Category with Id ${entity.taskCategoryId}: $e');
      }
    }

    if (entity.recurrenceId != null) {
      try {
        var recurrenceEntity =
            await recurrenceDao.getRecurrenceRuleById(entity.recurrenceId!);
        if (recurrenceEntity != null) {
          recurrenceRuleset = RecurrenceRuleset.fromEntity(recurrenceEntity);
        }
      } catch (e) {
        throw Exception(
            'Failed to get Recurrence Ruleset with Id ${entity.recurrenceId}: $e');
      }
    }

    var updatedTask = task.copyWith(
        taskCategory: category, recurrenceRuleset: recurrenceRuleset);

    return updatedTask;
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
      return getTaskFromEntity(taskEntity);
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
    final recurrenceDao = await _appDatabase.recurrenceDao;
    final recurringInstanceDao = await _appDatabase.recurringInstanceDao;
    final taskEntity = await Task.toTaskEntity(task);
    RecurrenceRulesetEntity? recurrenceEntity;
    int? recurrenceId;

    try {
      // Only proceed with recurrence if the task is recurring and has a ruleset and date
      if (task.isRecurring &&
          task.recurrenceRuleset != null &&
          task.date != null) {
        // Convert the recurrence ruleset to an entity
        recurrenceEntity = await task.recurrenceRuleset?.toEntity();

        // Insert the recurrence rule into the database and get the recurrence ID
        recurrenceId =
            await recurrenceDao.insertRecurrenceRule(recurrenceEntity!);
      }

      var updatedTaskEntity = taskEntity.copyWith(recurrenceId: recurrenceId);

      final insertedTaskEntity = await taskSource.addTask(updatedTaskEntity);

      var insertedTask = await getTaskFromEntity(insertedTaskEntity);

      // If task is recurring, generate and insert the recurring instances
      if (recurrenceEntity != null &&
          insertedTask.isRecurring &&
          insertedTask.recurrenceRuleset != null) {
        List<RecurringInstanceEntity> instances =
            await generateRecurringInstances(recurrenceEntity,
                insertedTask.date!, insertedTask.time!, insertedTask.id!);

        var count = 0;
        for (var instance in instances) {
          scheduleNotificationForRecurringInstance(
              instance, task.title ?? 'Recurring Task Reminder', suffix: count++);
        }

        await recurringInstanceDao.insertRecurringInstancesBatch(instances);
      }

      return insertedTask;
    } catch (e) {
      // Handle any database errors
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = await Task.toTaskEntity(task);

    try {
      final updatedEntity = await taskSource.updateTask(taskEntity);
      return await getTaskFromEntity(updatedEntity);
    } catch (e) {
      // Handle database errors
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> bulkUpdateTasks(
      List<int> taskIds, TaskCategory? newCategory, bool? markComplete) async {
    final taskSource = await _appDatabase.taskDatasource;

    final updateMap = <String, dynamic>{};

    if (newCategory != null) {
      updateMap[taskCategoryIdField] =
          newCategory.id; // Assuming this field is used for categories
    }
    if (markComplete != null) {
      updateMap[isDoneField] = markComplete ? 1 : 0;
    }

    try {
      // Iterate over task IDs and update each task with the new values
      for (var id in taskIds) {
        await taskSource.updateTaskFields(id, updateMap);
      }
    } catch (e) {
      throw Exception('Failed to bulk update tasks: $e');
    }
  }

  @override
  Future<void> completeTask(Task task) async {
    final taskSource = await _appDatabase.taskDatasource;
    final taskEntity = await Task.toTaskEntity(task);

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

// Function to create recurring instances based on the frequency from the ruleset
  Future<List<RecurringInstanceEntity>> generateRecurringInstances(
    RecurrenceRulesetEntity recurrenceRuleset, // The ruleset for recurrence
    DateTime startDate,
    TimeOfDay time,
    int taskId,
  ) async {
    List<RecurringInstanceEntity> instances = [];

    // Default to 7 instances if no count is provided
    int count = recurrenceRuleset.count ?? 7;

    // Calculate instances based on frequency
    for (int i = 0; i < count; i++) {
      DateTime occurrenceDate;
      TimeOfDay? occurrenceTime;

      switch (recurrenceRuleset.frequency) {
        case 'daily':
          // Add i days to the start date
          occurrenceDate = startDate.add(Duration(days: i));
          break;
        case 'weekly':
          // Add i weeks to the start date
          occurrenceDate = startDate.add(Duration(days: i * 7));
          break;
        case 'monthly':
          // Add i months to the start date
          occurrenceDate =
              DateTime(startDate.year, startDate.month + i, startDate.day);
          break;
        case 'yearly':
          // Add i years to the start date
          occurrenceDate =
              DateTime(startDate.year + i, startDate.month, startDate.day);
          break;
        default:
          // If no valid frequency is found, break the loop.
          throw Exception(
              "Unsupported frequency type: ${recurrenceRuleset.frequency}");
      }

      // Optionally, set a time for the instance (use startTime, or handle separately)
      occurrenceTime = time;

      // Create RecurringInstanceEntity for this occurrence
      RecurringInstanceEntity instance = RecurringInstanceEntity(
        taskId: taskId,
        occurrenceDate: occurrenceDate,
        occurrenceTime: occurrenceTime,
        isDone: 0, // 0 means the task is not done
      );

      instances.add(instance);
    }

    return instances;
  }
}
