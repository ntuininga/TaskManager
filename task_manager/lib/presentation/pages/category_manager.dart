import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    context.read<TaskCategoriesBloc>().add(const OnGettingTaskCategories(withLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Category Manager"),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TaskCategoriesBloc, TaskCategoriesState>(
              builder: (context, state) {
                if (state is LoadingGetTaskCategoriesState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SuccessGetTaskCategoriesState) {
                  // Filter out the "No Category" from the list
                  final categories = state.allCategories.where((category) => category.title != "No Category").toList();

                  if (categories.isEmpty) {
                    return const Center(child: Text("No Categories"));
                  }

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.colour,
                        ),
                        title: Text(category.title!),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<TaskCategoriesBloc>().add(DeleteTaskCategory(id: category.id!));
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UpdateCategoryPage(category: category),
                          ));
                        },
                      );
                    },
                  );
                } else if (state is NoTaskCategoriesState) {
                  return const Center(child: Text("No Categories"));
                } else if (state is TaskCategoryErrorState) {
                  return Center(child: Text(state.errorMsg));
                } else {
                  return const Center(child: Text("Unknown error"));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => showNewCategoryBottomSheet(context),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
