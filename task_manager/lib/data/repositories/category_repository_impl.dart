import 'package:task_manager/data/datasources/local/dao/task_dao.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final TaskDatasource _taskDatasource;

  CategoryRepositoryImpl(this._taskDatasource);

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
