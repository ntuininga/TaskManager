import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/pages/update_category.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_category_bottom_sheet.dart';

class CategoryManager extends StatefulWidget {
  const CategoryManager({super.key});

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  @override
  void initState() {
    super.initState();
    // Fetch categories and tasks on initial load
    context.read<TaskCategoriesBloc>().add(const OnGettingTaskCategories(withLoading: true));
    context.read<TasksBloc>().add(OnGettingTasksEvent(withLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            // Delay event firing to ensure UI consistency
            Future.microtask(() => context.read<TasksBloc>().add(RefreshTasksEvent()));
          },
        ),
        title: const Text("Category Manager"),
      ),
      body: BlocConsumer<TaskCategoriesBloc, TaskCategoriesState>(
        listener: (context, state) {
          if (state is CategoriesUpdatedState) {
            // After deletion, refresh categories
            context.read<TaskCategoriesBloc>().add(const OnGettingTaskCategories(withLoading: false));

            context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: false));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Category deleted successfully.")),
            );
          } else if (state is TaskCategoryErrorState) {
            // Show error message if deletion failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMsg ?? "An unexpected error occurred.")),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingGetTaskCategoriesState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SuccessGetTaskCategoriesState) {
            // Filter out "No Category"
            final categories = state.allCategories
                .where((category) => category.title != "No Category")
                .toList();

            if (categories.isEmpty) {
              return const Center(child: Text("No Categories"));
            }

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.colour ?? Colors.grey,
                  ),
                  title: Text(category.title ?? "Unnamed Category"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Trigger the category deletion
                      context.read<TaskCategoriesBloc>().add(DeleteTaskCategory(id: category.id!));
                    },
                  ),
                  onTap: () {
                    // Navigate to category update page
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UpdateCategoryPage(category: category),
                    )).then((_) {
                      // After returning from update, re-fetch categories
                      context.read<TaskCategoriesBloc>().add(const OnGettingTaskCategories(withLoading: false));
                    });
                  },
                );
              },
            );
          } else if (state is NoTaskCategoriesState) {
            return const Center(child: Text("No Categories"));
          } else if (state is TaskCategoryErrorState) {
            return Center(child: Text(state.errorMsg ?? "An unexpected error occurred."));
          } else {
            return const Center(child: Text("Unknown error"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewCategoryBottomSheet(context),
        tooltip: "Add New Category",
        child: const Icon(Icons.add),
      ),
    );
  }
}
