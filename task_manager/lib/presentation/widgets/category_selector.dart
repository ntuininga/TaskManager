import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';

class CategorySelector extends StatefulWidget {
  final Function(TaskCategory) onCategorySelected;
  // final GlobalKey<_CategorySelectorState> key;

  const CategorySelector({required this.onCategorySelected, Key? key}) : super(key: key);

  @override
  State<CategorySelector> createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  TaskCategory? category;

  void resetCategory() {
    setState(() {
      category = null;
    });
  }

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
      child: Text(
        "${category == null ? "No Category" : category!.title}",
        style: category != null ? TextStyle(color: category!.colour) : null,
      ),
    );
  }
}
