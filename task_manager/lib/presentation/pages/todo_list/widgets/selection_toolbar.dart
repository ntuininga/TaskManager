import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class SelectionToolbar extends StatefulWidget {
  final int selectedCount;
  final TaskCategory? bulkSelectedCategory;
  final Function(TaskCategory?) onCategorySelected;
  final Function(bool?) onBulkCompleteChanged;
  final Function() onConfirmPressed;
  final Function() onDeleteConfirmed;
  final Function() onClosePressed;
  final bool initialBulkComplete;

  const SelectionToolbar({
    super.key,
    required this.selectedCount,
    this.bulkSelectedCategory,
    required this.onCategorySelected,
    required this.onBulkCompleteChanged,
    required this.onConfirmPressed,
    required this.onDeleteConfirmed,
    required this.onClosePressed,
    this.initialBulkComplete = false,
  });

  @override
  State<SelectionToolbar> createState() => _SelectionToolbarState();
}

class _SelectionToolbarState extends State<SelectionToolbar> {
  bool _deletePressed = false;
  bool _isBulkComplete = false;

  @override
  void initState() {
    super.initState();
    _isBulkComplete = widget.initialBulkComplete;
  }

  void _handleDelete() {
    if (_deletePressed) {
      widget.onDeleteConfirmed(); // calls AnimatedTaskList._deleteSelected()
      setState(() => _deletePressed = false);
    } else {
      setState(() => _deletePressed = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _deletePressed = false);
      });
    }
  }


  void _handleCheckboxChanged(bool? value) {
    setState(() => _isBulkComplete = value ?? false);
    widget.onBulkCompleteChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).canvasColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete),
            color: _deletePressed ? Colors.red : Theme.of(context).dividerColor,
          ),
          IconButton(
            onPressed: widget.onClosePressed,
            icon: const Icon(Icons.close),
          ),
          Text(
            '${widget.selectedCount} selected',
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          SizedBox(
            height: 26,
            child: CategorySelector(
              maxWidth: 100,
              selectedCategory: widget.bulkSelectedCategory,
              onCategorySelected: widget.onCategorySelected,
            ),
          ),
          Checkbox(
            value: _isBulkComplete,
            onChanged: _handleCheckboxChanged,
          ),
          IconButton(
            onPressed: widget.onConfirmPressed,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
