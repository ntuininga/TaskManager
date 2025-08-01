import 'package:task_manager/data/datasources/local/dao/recurring_task_dao.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/repositories/recurring_details_repository.dart';

class RecurringTaskRepositoryImpl implements RecurringTaskRepository {
  final RecurringTaskDao dao;

  RecurringTaskRepositoryImpl(this.dao);

  @override
  Future<RecurringTaskDetails> fetchDetailsByTaskId(int taskId) async {
    final entity = await dao.fetchDetailsByTaskId(taskId);
    return RecurringTaskDetails.fromEntity(entity);
  }

  @override
  Future<List<RecurringTaskDetails>> getAllRecurringTasks() async {
    final entities = await dao.getAllRecurringTasks();
    return entities.map(RecurringTaskDetails.fromEntity).toList();
  }

  @override
  Future<void> clearAllScheduledDates(int taskId) async {
    await dao.clearAllScheduledDates(taskId);
  }

  @override
  Future<void> updateScheduledDates(int taskId, {
    List<DateTime>? newScheduledDates,
    List<DateTime>? newCompletedDates,
    List<DateTime>? newMissedDates,
  }) async {
    await dao.updateExistingDates(
      taskId: taskId,
      newScheduledDates: newScheduledDates,
      newCompletedDates: newCompletedDates,
      newMissedDates: newMissedDates,
    );
  }

  @override
  Future<void> addNewScheduledDates(int taskId, List<DateTime> newDates) async {
    return await dao.insertNewDates(
        taskId: taskId, newScheduledDates: newDates);
  }

  @override
  Future<void> updateCompletedOnDates(
      int taskId, List<DateTime> completedDates) async {
    return await dao.updateCompletedOnDates(taskId, completedDates);
  }

  @override
  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates) async {
    return await dao.updateMissedDates(taskId, missedDates);
  }

  @override
  Future<List<DateTime>> getAllScheduledDates(int taskId) async {
    return await dao.getAllScheduledDates(taskId);
  }

  @override
  Future<void> addCompletedDate(int taskId, DateTime completedDate) async {
    return await dao.addCompletedDate(taskId, completedDate);
  }

  @override
  Future<void> removeScheduledDate(int taskId, DateTime scheduledDate) async {
    return await dao.removeScheduledDate(taskId, scheduledDate);
  }
}
