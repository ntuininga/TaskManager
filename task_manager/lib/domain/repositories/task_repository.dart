import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getUncompletedNonRecurringTasks();
  Future<Task> getTaskById(int id);
  Future<List<Task>> getTasksByCategory(int categoryId);
  Future<List<Task>> getUnfinishedTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getTasksBetweenDates(DateTime start, DateTime end);
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> bulkUpdateTasks(
      List<int> taskIds, TaskCategory? newCategory, bool? markComplete);
  Future<void> completeTask(Task task);
  Future<void> deleteAllTasks();
  Future<void> deleteTaskById(int id);
  Future<void> removeCategoryFromTasks(int categoryId);

  Future<List<TaskCategory>> getAllCategories();
  Future<void> addTaskCategory(TaskCategory category);
  Future<TaskCategory> getCategoryById(int id);
  Future<TaskCategory> updateTaskCategory(TaskCategory category);
  Future<void> deleteTaskCategory(int id);
}
