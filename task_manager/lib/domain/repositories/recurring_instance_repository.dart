import 'package:task_manager/domain/models/recurring_instance.dart';

abstract class RecurringInstanceRepository {
  /// Insert a single recurring instance
  Future<int> insertInstance(RecurringInstance instance);

  /// Insert multiple recurring instances as a batch
  Future<void> insertInstancesBatch(List<RecurringInstance> instances);

  /// Get all recurring instances by taskId
  Future<List<RecurringInstance>> getInstancesByTaskId(int taskId);

  /// Get a specific recurring instance by ID
  Future<RecurringInstance?> getInstanceById(int instanceId);

  /// Update a single recurring instance
  Future<int> updateInstance(RecurringInstance instance);

  /// Update multiple recurring instances as a batch
  Future<void> updateInstancesBatch(List<RecurringInstance> instances);

  /// Delete a specific recurring instance by ID
  Future<int> deleteInstance(int instanceId);

  /// Delete all recurring instances for a specific task
  Future<int> deleteInstancesByTaskId(int taskId);

  /// Get all recurring instances within a date range
  Future<List<RecurringInstance>> getInstancesByDateRange(DateTime start, DateTime end);

  /// Get all recurring instances that are not marked as done
  Future<List<RecurringInstance>> getUncompletedInstances();

  /// Mark a specific instance as completed
  Future<int> completeInstance(int instanceId, DateTime completedAt);

  /// Count all instances linked to a specific task
  Future<int> countInstancesByTaskId(int taskId);
}
