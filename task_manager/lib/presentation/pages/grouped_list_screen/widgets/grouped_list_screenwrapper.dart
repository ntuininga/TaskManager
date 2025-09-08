import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/pages/grouped_list_screen/grouped_list_screen.dart';

class GroupedListScreenWrapper extends StatelessWidget {
  final TaskCategory? category;
  final String? title;
  final FilterType? specialFilter;

  const GroupedListScreenWrapper({super.key, this.category, this.title, this.specialFilter});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskCategoriesBloc, TaskCategoriesState>(
      listener: (context, state) {
        // Only pop if this specific category was deleted
        if (state is CategoriesUpdatedState &&
            !state.updatedCategories.any((c) => c.id == category?.id)) {
          Navigator.of(context).pop();
        }
      },
      child: GroupedListScreen(
        category: category,
        title: title,
        specialFilter: specialFilter,
      ),
    );
  }
}
