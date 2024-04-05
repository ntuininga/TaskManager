const String taskTableName = "tasks";

const String idField = "_id";
const String titleField = "title";
const String descriptionField = "description";
const String isDoneField = "is_done";

const List<String> taskColumns = [
  idField,
  titleField,
  descriptionField,
  isDoneField
];




class Task {
  final int? id;
  final String title;
  final String? description;
  bool isDone;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isDone = false
  });

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json[idField] as int,
    title: json[titleField] as String,
    description: json[descriptionField] as String?,
    isDone: json[isDoneField] == 1
  );

  Map<String, dynamic> toJson() => {
    idField: id,
    titleField: title,
    descriptionField: description,
    isDoneField: isDone
  };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
  }) => Task (
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone
  );
}