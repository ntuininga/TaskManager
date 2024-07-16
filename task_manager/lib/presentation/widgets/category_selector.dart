import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';

class CategorySelector extends StatefulWidget {
  final Function(TaskCategory) onCategorySelected;

  const CategorySelector({Key? key, required this.onCategorySelected}) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  TaskCategory? category;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var selectedCategory = await showCategoriesDialog(context);
        if (selectedCategory != null) {
          setState(() {
            category = selectedCategory;
          });
          widget.onCategorySelected(selectedCategory);
        }
      },
      child: Text("${category == null ? "No Category" : category!.title}"),
    );
  }
}
