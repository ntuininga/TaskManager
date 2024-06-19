import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getUnfinishedTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getTasksBetweenDates(DateTime start, DateTime end);
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> completeTask(Task task);
  Future<void> deleteAllTasks();
  Future<void> deleteTaskById(int id);

  Future<List<TaskCategory>> getAllCategories();
  Future<void> addTaskCategory(TaskCategory category);
  Future<TaskCategory> getCategoryById(int id);
}
