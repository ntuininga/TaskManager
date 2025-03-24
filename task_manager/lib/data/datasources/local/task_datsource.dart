import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/recurring_task_details_entity.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/data/entities/task_entity.dart';

class TaskDatasource {
  final sqflite.Database db;

  TaskDatasource(this.db);

  Future<List<TaskEntity>> getAllTasks() async {
    try {
      final result = await db.query(taskTableName);
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskEntity> getTaskById(int id) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        taskTableName,
        where: '$idField = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return TaskEntity.fromJson(result.first);
      } else {
        throw Exception('Task with ID $id not found');
      }
    } catch (e) {
      print('Error getting task by id: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getTasksByCategory(int categoryId) async {
    try {
      final result = await db.query(
        taskTableName,
        where: '$taskCategoryIdField = ?', // Use placeholder here
        whereArgs: [categoryId],
      );

      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TaskEntity>> getUnfinishedTasks() async {
    try {
      final result = await db.query(
        taskTableName,
        where: '$isDoneField = ?',
        whereArgs: [0], // SQLite does not have a boolean type
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting unfinished tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getCompletedTasks() async {
    try {
      final result = await db.query(
        taskTableName,
        where: '$isDoneField = ?',
        whereArgs: [1], // SQLite does not have a boolean type
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting completed tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<List<TaskEntity>> getTasksBetweenDates(
      DateTime start, DateTime end) async {
    try {
      final result = await db.query(
        taskTableName,
        where: 'date >= ? AND date < ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
      );
      return result.map((json) => TaskEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting tasks between dates: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskEntity> addTask(TaskEntity task) async {
    try {
      final taskToInsert =
          task.copyWith(taskCategoryId: task.taskCategoryId ?? 0);
      final taskId = await db.insert(taskTableName, taskToInsert.toJson());
      return task.copyWith(id: taskId);
    } catch (e) {
      print('Error adding task: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskEntity> updateTask(TaskEntity task) async {
    try {
      await db.update(
        taskTableName,
        task.toJson(),
        where: '$idField = ?',
        whereArgs: [task.id],
      );
      return task;
    } catch (e) {
      print('Error updating task: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> completeTask(TaskEntity task) async {
    try {
      var completedTask =
          task.copyWith(completedDate: DateTime.now(), isDone: 1);
      await db.update(
        taskTableName,
        completedTask.toJson(),
        where: '$idField = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print('Error completing task: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteAllTasks() async {
    try {
      await db.execute("DROP TABLE IF EXISTS $taskTableName");
      await db.execute("DROP TABLE IF EXISTS $recurringDetailsTableName");
      await AppDatabase.instance.createTaskTable(db);
      await AppDatabase.instance.createRecurringTaskTable(db);
    } catch (e) {
      print('Error deleting all tasks: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteTaskById(int id) async {
    try {
      await db.delete(
        taskTableName,
        where: "$idField = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task by id: $e'); // Logging error
      rethrow;
    }
  }

  // Task Categories
  Future<List<TaskCategoryEntity>> getAllCategories() async {
    try {
      final result = await db.query(taskCategoryTableName);
      return result.map((json) => TaskCategoryEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting all categories: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> addTaskCategory(
      TaskCategoryEntity category) async {
    try {
      final categoryId =
          await db.insert(taskCategoryTableName, category.toJson());
      return category.copyWith(id: categoryId);
    } catch (e) {
      print('Error adding task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> updateTaskCategory(
      TaskCategoryEntity category) async {
    try {
      await db.update(
        taskCategoryTableName,
        category.toJson(),
        where: '$categoryIdField = ?',
        whereArgs: [category.id],
      );
      return category;
    } catch (e) {
      print('Error updating task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<void> deleteTaskCategory(int id) async {
    try {
      await db.delete(
        taskCategoryTableName,
        where: "$categoryIdField = ?",
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting task category: $e'); // Logging error
      rethrow;
    }
  }

  Future<TaskCategoryEntity> getCategoryById(int id) async {
    try {
      final List<Map<String, dynamic>> result = await db.query(
        taskCategoryTableName,
        where: '$categoryIdField = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return TaskCategoryEntity.fromJson(result.first);
      } else {
        // Return the default category if the category isn't found
        return await getCategoryById(0); // This fetches the default category
      }
    } catch (e) {
      print('Error getting category by id: $e');
      // Return the default category in case of an error
      return await getCategoryById(0);
    }
  }

  Future<void> updateTaskFields(int taskId, Map<String, dynamic> fields) async {
    // final db = await database;
    await db.update(
      'tasks',
      fields,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

Future<void> handleRecurringTasksOnStartup() async {
  try {
    print("Checking Recurring Tasks");
    final recurringTasksResult = await db.query(recurringDetailsTableName);

    for (var taskDetails in recurringTasksResult) {
      final recurringTask = RecurringTaskDetailsEntity.fromJson(taskDetails);

      final scheduledDates = recurringTask.scheduledDates ?? [];
      final missedDates = recurringTask.missedDates ?? [];

      // Ensure scheduledDates are DateTime objects
      final today = DateTime.now().toLocal();
      final todayMidnight = DateTime(today.year, today.month, today.day); // Normalize to midnight

      print("Today (Midnight): $todayMidnight");
      print("Scheduled Dates: $scheduledDates");
      print("Missed Dates: $missedDates");

      // Normalize all scheduled dates to ignore the time component
      final normalizedScheduledDates = scheduledDates
          .map((date) => DateTime(date.year, date.month, date.day)) // Normalize each date
          .toList();

      print("Normalized Scheduled Dates: $normalizedScheduledDates");

      // Find missing dates that are before today and are not in missedDates
      final missingDates = normalizedScheduledDates.where((date) {
        final isBeforeToday = date.isBefore(todayMidnight); // Date comparison
        final isNotInMissedDates = !missedDates.contains(date);
        print("Checking date: $date, Is Before Today: $isBeforeToday, Is Not In Missed Dates: $isNotInMissedDates");
        return isBeforeToday && isNotInMissedDates;
      }).toList();

      if (missingDates.isNotEmpty) {
        print("Missing Dates: $missingDates");

        // Update missedDates and scheduledDates accordingly
        final updatedMissedDates = List<DateTime>.from(missedDates)..addAll(missingDates);
        final updatedScheduledDates = normalizedScheduledDates
            .where((date) => !missingDates.contains(date))
            .toList();

        RecurringTaskDetailsEntity newDetails = RecurringTaskDetailsEntity(
          taskId: recurringTask.taskId,
          scheduledDates: updatedScheduledDates,
          missedDates: updatedMissedDates,
          completedOnDates: recurringTask.completedOnDates,
        );

        final updatedTaskData = newDetails.toJson();

        // Update recurring task data in the database
        await db.update(
          recurringDetailsTableName,
          updatedTaskData,
          where: '$idField = ?',
          whereArgs: [recurringTask.taskId],
        );

        // Step 3: Create new tasks for any missed dates
        for (var missedDate in missingDates) {
          await _createTaskFromRecurringTask(recurringTask, missedDate);
        }
      }
    }
  } catch (e) {
    print('Error handling recurring tasks on startup: $e');
    rethrow;
  }
}



  Future<void> _createTaskFromRecurringTask(
      RecurringTaskDetailsEntity recurringTask, DateTime missedDate) async {
    try {
      // Extract task details from recurring task
      final task = await getTaskById(recurringTask.taskId!);

      // Create a new task for the missed date
      final newTask = TaskEntity(
        title: task.title,
        description: task.description,
        isDone: 0,
        taskCategoryId: task.taskCategoryId,
        date: missedDate,
        createdOn: DateTime.now(),
        urgencyLevel: task.urgencyLevel,
        time: task.time,
      );

      // Insert the new task into the tasks table
      await addTask(newTask);
    } catch (e) {
      print('Error creating task from recurring task: $e');
      rethrow;
    }
  }
}
