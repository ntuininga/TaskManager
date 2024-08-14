import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/pages/category_manager.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_category_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/category_card.dart';

Future<TaskCategory?> showCategoriesDialog(BuildContext context) async {
  final TaskCategory? selectedCategory = await showDialog<TaskCategory?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CategoryManager(),
                    ));
                  },
                  child: const Text(
                    "Manage",
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<TaskCategoriesBloc, TaskCategoriesState>(
              builder: (context, state) {
                if (state is LoadingGetTaskCategoriesState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SuccessGetTaskCategoriesState) {
                  return _buildCategoryList(state.allCategories);
                } else if (state is NoTaskCategoriesState) {
                  return const Center(child: Text("No Categories"));
                } else {
                  return const Center(child: Text("Error has occurred"));
                }
              },
            ),
            ElevatedButton(
              onPressed: () => showNewCategoryBottomSheet(context),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      );
    },
  );

  return selectedCategory;
}


Widget _buildCategoryList(List<TaskCategory> categories) {
  return SizedBox(
    height: 300,
    width: 200,
    child: ListView.builder(
      itemCount: categories.length + 1, // +1 for the "No Category" option
      itemBuilder: (context, index) {
        if (index < categories.length) {
          return CategoryCard(category: categories[index]);
        } else {
          // This is the last item, so show the "No Category" option
          return ListTile(
            title: const Text("No Category"),
            onTap: () {
              Navigator.of(context).pop(null); // null indicates "No Category"
            },
          );
        }
      },
    ),
  );
}

