import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getUnfinishedTasks();
  Future<List<Task>> getCompletedTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteAllTasks();

  Future<List<TaskCategory>> getAllCategories();
  Future<void> addTaskCategory(TaskCategory category);
  Future<TaskCategory> getCategoryById(int id);
}