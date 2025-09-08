import 'package:task_manager/domain/models/task_category.dart';

abstract class CategoryRepository {
  Future<List<TaskCategory>> getAllCategories();
  Future<void> addTaskCategory(TaskCategory category);
  Future<TaskCategory> updateTaskCategory(TaskCategory category);
  Future<void> deleteTaskCategory(int id);
  Future<TaskCategory> getCategoryById(int id);
}
