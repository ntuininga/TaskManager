import 'package:json_annotation/json_annotation.dart';

const String userTableName = "user";

const String userIdField = "_id";
const String completedTasksField = "completed_tasks";
const String pendingTasksField = "pending_tasks";

@JsonSerializable()
class UserEntity {
  final int? id;
  final int? completedTasks;
  final int? pendingTasks;

  UserEntity({
    this.id,
    this.completedTasks,
    this.pendingTasks,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  UserEntity copyWith({
    int? id,
    int? completedTasks,
    int? pendingTasks,
  }) {
    return UserEntity(
      id: id ?? this.id,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
    );
  }
}

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      id: json[userIdField] as int?,
      completedTasks: json[completedTasksField] as int?,
      pendingTasks: json[pendingTasksField] as int?,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity entity) => {
      userIdField: entity.id,
      completedTasksField: entity.completedTasks,
      pendingTasksField: entity.pendingTasks,
    };
