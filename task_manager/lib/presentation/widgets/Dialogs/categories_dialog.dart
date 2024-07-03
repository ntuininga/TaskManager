import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/widgets/category_card.dart';

Future<TaskCategory?> showCategoriesDialog(BuildContext context) async {
  final TaskCategory? selectedCategory = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Categories"),
          content: BlocBuilder<TaskCategoriesBloc, TaskCategoriesState>(
              builder: ((context, state) {
            if (state is LoadingGetTaskCategoriesState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SuccessGetTaskCategoriesState) {
              return _buildCategoryList(state.allCategories);
            } else if (state is NoTaskCategoriesState) {
              return const Center(child: Text("No Categories"));
            } else {
              return const Center(child: Text("Error has occured"));
            }
          })),
        );
      });

    return selectedCategory;
}

Widget _buildCategoryList(List<TaskCategory> categories) {
  return SizedBox(
    height: 300,
    width: 200,
    child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: ((context, index) {
          return CategoryCard(category: categories[index]);
        })),
  );
}
