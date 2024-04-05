const String taskCategoryTableName = "taskcategories";

const String categoryIdField = "_id";
const String categoryTitleField = "title";

const List<String> taskCategoryColumns = [
  categoryIdField,
  categoryTitleField
];

class TaskCategory {
  final int? id;
  final String title;

  TaskCategory({
    this.id,
    required this.title
  });

  static TaskCategory fromJson(Map<String, dynamic> json) => TaskCategory(
    id: json[categoryIdField] as int,
    title: json[categoryTitleField] as String
  );  

  Map<String, dynamic> toJson() => {
    categoryIdField: id,
    categoryTitleField: title,
  };

  TaskCategory copyWith({
    int? id,
    String? title
  }) => TaskCategory (
    id: id ?? this.id,
    title: title ?? this.title
  );
}
