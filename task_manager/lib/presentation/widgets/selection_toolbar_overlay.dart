import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/selection_toolbar.dart';

typedef OnBulkCompleteChanged = void Function(bool? value);
typedef OnCategorySelected = void Function(TaskCategory? category);

class SelectionToolbarOverlay extends StatefulWidget {
  final int selectedCount;
  final TaskCategory? bulkSelectedCategory;
  final bool initialBulkComplete;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback onClosePressed;
  final VoidCallback onConfirmPressed;
  final OnBulkCompleteChanged onBulkCompleteChanged;
  final OnCategorySelected onCategorySelected;

  const SelectionToolbarOverlay({
    super.key,
    required this.selectedCount,
    required this.onDeleteConfirmed,
    required this.onClosePressed,
    required this.onConfirmPressed,
    required this.onBulkCompleteChanged,
    required this.onCategorySelected,
    this.bulkSelectedCategory,
    this.initialBulkComplete = false,
  });

  @override
  State<SelectionToolbarOverlay> createState() =>
      _SelectionToolbarOverlayState();

  /// Static helper to show overlay
  static OverlayEntry show({
    required BuildContext context,
    required SelectionToolbarOverlay overlay,
  }) {
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: overlay,
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(entry);
    return entry;
  }
}

class _SelectionToolbarOverlayState extends State<SelectionToolbarOverlay> {
  @override
  Widget build(BuildContext context) {
    return SelectionToolbar(
      selectedCount: widget.selectedCount,
      bulkSelectedCategory: widget.bulkSelectedCategory,
      initialBulkComplete: widget.initialBulkComplete,
      onDeleteConfirmed: widget.onDeleteConfirmed,
      onClosePressed: widget.onClosePressed,
      onConfirmPressed: widget.onConfirmPressed,
      onBulkCompleteChanged: widget.onBulkCompleteChanged,
      onCategorySelected: widget.onCategorySelected,
    );
  }
}
