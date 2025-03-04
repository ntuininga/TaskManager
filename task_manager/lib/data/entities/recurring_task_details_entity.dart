import 'package:json_annotation/json_annotation.dart';
part 'recurring_task_details_entity.g.dart';

const String recurringDetailsTableName = "recurringTaskDetails";

const String taskIdField = "taskId";
const String scheduledTasksField = "scheduledTasks";
const String completedOnTasksField = "completedOnTasks";
const String missedDatesFields = "missedDatesField";

@JsonSerializable()
class RecurringTaskDetailsEntity {
  int? taskId;

  @JsonKey(fromJson: _decodeDates, toJson: _encodeDates)
  List<DateTime>? scheduledDates;

  @JsonKey(fromJson: _decodeDates, toJson: _encodeDates)
  List<DateTime>? completedOnDates;

  @JsonKey(fromJson: _decodeDates, toJson: _encodeDates)
  List<DateTime>? missedDates;

  RecurringTaskDetailsEntity({
    this.taskId,
    this.scheduledDates,
    this.completedOnDates,
    this.missedDates,
  });

  factory RecurringTaskDetailsEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurringTaskDetailsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringTaskDetailsEntityToJson(this);

  // Helper methods for serialization
  static List<DateTime>? _decodeDates(String? datesString) {
    if (datesString == null || datesString.isEmpty) return null;
    return datesString.split(",").map((date) => DateTime.parse(date)).toList();
  }

  static String? _encodeDates(List<DateTime>? dates) {
    if (dates == null || dates.isEmpty) return null;
    return dates.map((date) => date.toIso8601String()).join(",");
  }
}

