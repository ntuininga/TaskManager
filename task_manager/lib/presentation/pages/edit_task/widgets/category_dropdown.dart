import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

class CategoryDropdown extends StatefulWidget {
  final TaskCategory? selectedCategory;
  final ValueChanged<TaskCategory?> onChanged;

  const CategoryDropdown({
    super.key,
    this.selectedCategory,
    required this.onChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCategoriesBloc, TaskCategoriesState>(
      builder: (context, state) {
        if (state is LoadingGetTaskCategoriesState) {
          return const CircularProgressIndicator();
        } else if (state is SuccessGetTaskCategoriesState) {
          final categories = state.allCategories.toSet().toList();

          if (categories.isEmpty) {
            return const Text("No categories available");
          }

          final validSelectedCategory = categories.contains(widget.selectedCategory)
              ? widget.selectedCategory
              : null;

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withOpacity(0.95),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<TaskCategory>(
                value: validSelectedCategory,
                hint: const Text('Select a category'),
                isExpanded: false,
                underline: const SizedBox(), // Removes the underline
                onChanged: widget.onChanged,
                items: _buildDropdownItems(categories),
                dropdownColor: Theme.of(context).cardColor,
              ),
            ),
          );
        } else if (state is NoTaskCategoriesState) {
          return const Text("No categories available");
        } else if (state is TaskCategoryErrorState) {
          return Text("Error: ${state.errorMsg}");
        } else {
          return const SizedBox();
        }
      },
    );
  }

  List<DropdownMenuItem<TaskCategory>> _buildDropdownItems(List<TaskCategory> categories) {
    return categories.map((category) {
      return DropdownMenuItem<TaskCategory>(
        value: category,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: category.colour ?? Colors.grey,
              radius: 8.0,
            ),
            const SizedBox(width: 10),
            Text(category.title ?? 'Unnamed Category'),
          ],
        ),
      );
    }).toList();
  }
}
