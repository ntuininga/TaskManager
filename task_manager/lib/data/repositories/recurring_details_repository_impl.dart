import 'package:task_manager/data/datasources/local/recurring_task_dao.dart';
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
  Future<void> addNewScheduledDates(int taskId, List<DateTime> newDates) async {
    return await dao.addScheduledDates(taskId, newDates);
  }

  @override
  Future<void> updateCompletedOnDates(int taskId, List<DateTime> completedDates) async {
    return await dao.updateCompletedOnDates(taskId, completedDates);
  }

  @override
  Future<void> updateMissedDates(int taskId, List<DateTime> missedDates) async {
    return await dao.updateMissedDates(taskId, missedDates);
  }
}
