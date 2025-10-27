import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class Filter {
  FilterType filterType;
  TaskCategory? filteredCategory;

  Filter(this.filterType, this.filteredCategory);

  Filter copyWith({
    FilterType? filterType,
    TaskCategory? filteredCategory,
  }) {
    return Filter(
      filterType ?? this.filterType,
      filteredCategory ?? this.filteredCategory,
    );
  }
}
