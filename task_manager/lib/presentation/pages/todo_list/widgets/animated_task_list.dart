import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final bool isDeletePressed;
  final bool? isBulkComplete;
  final TaskCategory? bulkSelectedCategory;
  final Function() onDeletePressed;
  final Function() onClosePressed;
  final Function(TaskCategory?) onCategorySelected;
  final Function(bool?) onBulkCompleteChanged;
  final Function() onConfirmPressed;

  const SelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.isDeletePressed,
    required this.isBulkComplete,
    required this.bulkSelectedCategory,
    required this.onDeletePressed,
    required this.onClosePressed,
    required this.onCategorySelected,
    required this.onBulkCompleteChanged,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).canvasColor,
      child: Row(
        children: [
          IconButton(
            onPressed: onDeletePressed,
            icon: const Icon(Icons.delete),
            color:
                isDeletePressed ? Colors.red : Theme.of(context).dividerColor,
          ),
          IconButton(
            onPressed: onClosePressed,
            icon: const Icon(Icons.close),
          ),
          Text(
            '$selectedCount selected',
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          SizedBox(
            height: 26,
            child: CategorySelector(
              maxWidth: 100,
              onCategorySelected: onCategorySelected,
            ),
          ),
          Checkbox(
            value: isBulkComplete,
            onChanged: onBulkCompleteChanged,
          ),
          IconButton(
            onPressed: onConfirmPressed,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
