import 'package:flutter/material.dart';
import 'package:task_manager/core/utils/colour_utils.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/buttons/rounded_button.dart';

class CategorySelector extends StatefulWidget {
  final TaskCategory? initialCategory;
  final Function(TaskCategory) onCategorySelected;

  const CategorySelector({
    this.initialCategory,
    required this.onCategorySelected,
    Key? key,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => CategorySelectorState();
}

class CategorySelectorState extends State<CategorySelector> {
  TaskCategory? category;

  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
  }

  void resetCategory() {
    setState(() {
      category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      onPressed: () async {
        var selectedCategory = await showCategoriesDialog(context);
        if (selectedCategory != null) {
          setState(() {
            category = selectedCategory;
          });
          widget.onCategorySelected(selectedCategory);
        }
      },
      text: category?.title ?? "Category",
      textColor: category?.colour ??
          Theme.of(context)
              .buttonTheme
              .colorScheme!
              .primary, // Provide default color if null
      backgroundColor: category?.colour != null
          ? lightenColor(category!.colour!)
          : Theme.of(context).buttonTheme.colorScheme!.background,
    );
  }
}
