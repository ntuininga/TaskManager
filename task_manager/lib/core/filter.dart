import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class Filter {
  FilterType activeFilter;
  TaskCategory? filteredCategory;

  Filter(this.activeFilter, this.filteredCategory);
}
