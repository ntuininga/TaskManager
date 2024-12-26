import 'package:flutter/material.dart';
import 'package:task_manager/core/utils/colour_utils.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/buttons/rounded_button.dart';

class CategorySelector extends StatefulWidget {
  final TaskCategory? initialCategory;
  final TaskCategory? selectedCategory;
  final Function(TaskCategory) onCategorySelected;
  final Function(TaskCategory?)? onCategoryUpdated;
  final bool hasCircle;
  final double maxWidth;

  const CategorySelector({
    this.initialCategory,
    this.selectedCategory,
    required this.onCategorySelected,
    this.onCategoryUpdated,
    this.hasCircle = false,
    this.maxWidth = 200.0,
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
    category = widget.initialCategory ?? widget.selectedCategory;
  }

  // Method to externally update the category
  void updateCategory(TaskCategory newCategory) {
    setState(() {
      category = newCategory;
    });
    widget.onCategorySelected(newCategory); // Notify parent about the change
    if (widget.onCategoryUpdated != null) {
      widget.onCategoryUpdated!(
          newCategory); // Notify if external callback is provided
    }
  }

  // Method to reset category
  void resetCategory() {
    setState(() {
      category = null;
    });
    if (widget.onCategoryUpdated != null) {
      widget.onCategoryUpdated!(null); // Notify parent about reset
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: RoundedButton(
        maxWidth: widget.maxWidth,
        onPressed: () async {
          var selectedCategory = await showCategoriesDialog(context);
          if (selectedCategory != null) {
            updateCategory(
                selectedCategory); // Update the category with the selection
          }
        },
        hasCircle: category != null && widget.hasCircle,
        text: category?.title ?? "Category",
        textColor: category?.colour ??
            Theme.of(context)
                .buttonTheme
                .colorScheme!
                .primary, // Provide default color if null
        backgroundColor: category?.colour != null
            ? lightenColor(category!.colour!)
            : Theme.of(context).buttonTheme.colorScheme!.surface,
      ),
    );
  }
}
