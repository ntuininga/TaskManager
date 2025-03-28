import 'package:task_manager/data/datasources/local/dao/recurring_instance_dao.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
import 'package:task_manager/domain/repositories/recurring_instance_repository.dart';

class RecurringInstanceRepositoryImpl implements RecurringInstanceRepository {
  final RecurringInstanceDao dao;

  RecurringInstanceRepositoryImpl(this.dao);

  /// Insert a single recurring instance
  @override
  Future<int> insertInstance(RecurringInstance instance) async {
    return await dao.insertRecurringInstance(instance.toEntity());
  }

  /// Insert multiple recurring instances as a batch
  @override
  Future<void> insertInstancesBatch(List<RecurringInstance> instances) async {
    final entities = instances.map((e) => e.toEntity()).toList();
    await dao.insertRecurringInstancesBatch(entities);
  }

  /// Get all recurring instances by taskId
  @override
  Future<List<RecurringInstance>> getInstancesByTaskId(int taskId) async {
    final entities = await dao.getInstancesByTaskId(taskId);
    return entities.map(RecurringInstance.fromEntity).toList();
  }

  /// Get a specific recurring instance by ID
  @override
  Future<RecurringInstance?> getInstanceById(int instanceId) async {
    final entity = await dao.getInstanceById(instanceId);
    return entity != null ? RecurringInstance.fromEntity(entity) : null;
  }

  /// Update a single recurring instance
  @override
  Future<int> updateInstance(RecurringInstance instance) async {
    return await dao.updateRecurringInstance(instance.toEntity());
  }

  /// Update multiple recurring instances as a batch
  @override
  Future<void> updateInstancesBatch(List<RecurringInstance> instances) async {
    final entities = instances.map((e) => e.toEntity()).toList();
    await dao.updateRecurringInstancesBatch(entities);
  }

  /// Delete a specific recurring instance by ID
  @override
  Future<int> deleteInstance(int instanceId) async {
    return await dao.deleteRecurringInstance(instanceId);
  }

  /// Delete all recurring instances for a specific task
  @override
  Future<int> deleteInstancesByTaskId(int taskId) async {
    return await dao.deleteInstancesByTaskId(taskId);
  }

  /// Get all recurring instances within a date range
  @override
  Future<List<RecurringInstance>> getInstancesByDateRange(DateTime start, DateTime end) async {
    final entities = await dao.getInstancesByDateRange(start, end);
    return entities.map(RecurringInstance.fromEntity).toList();
  }

  /// Get all recurring instances that are not marked as done
  @override
  Future<List<RecurringInstance>> getUncompletedInstances() async {
    final entities = await dao.getUncompletedInstances();
    return entities.map(RecurringInstance.fromEntity).toList();
  }

  /// Mark a specific instance as completed
  @override
  Future<int> completeInstance(int instanceId, DateTime completedAt) async {
    return await dao.completeInstance(instanceId, completedAt);
  }

  /// Count all instances linked to a specific task
  @override
  Future<int> countInstancesByTaskId(int taskId) async {
    return await dao.countInstancesByTaskId(taskId);
  }
}
