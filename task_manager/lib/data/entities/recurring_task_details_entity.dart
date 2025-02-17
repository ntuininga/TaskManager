import 'package:json_annotation/json_annotation.dart';
part 'recurring_task_details_entity.g.dart';

const String recurringDetailsTableName = "recurringTaskDetails";

const String taskIdField = "id";
const String scheduledTasksField = "scheduledTasks";
const String completedOnTasksField = "completedOnTasks";
const String missedDatesFields = "missedDatesField";

@JsonSerializable()
class RecurringTaskDetailsEntity {
  int? taskId;
  List<DateTime>? scheduledDates;
  List<DateTime>? completedOnDates;
  List<DateTime>? missedDates;

  RecurringTaskDetailsEntity(
      {this.taskId,
      this.scheduledDates,
      this.completedOnDates,
      this.missedDates});

  factory RecurringTaskDetailsEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurringTaskDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringTaskDetailsToJson(this);
}
