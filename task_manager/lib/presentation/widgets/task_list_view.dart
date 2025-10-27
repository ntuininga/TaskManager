import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'task_card.dart';
import 'selection_toolbar_overlay.dart';

typedef TaskKey = String Function(Task task);

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final String dateFormat;
  final bool isCircleCheckbox;
  final void Function(Task task)? onCheckboxChanged;
  final void Function(Task task)? onTaskTap;
  final void Function(Task task)? onTaskLongPress;
  final TaskKey taskKey;

  /// Bulk actions
  final void Function(List<int> taskIds, bool markComplete)? onBulkComplete;
  final void Function(List<int> taskIds, TaskCategory? category)?
      onBulkCategoryChange;
  final void Function(List<int> taskIds)? onDeleteTasks;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.dateFormat,
    required this.isCircleCheckbox,
    this.onCheckboxChanged,
    this.onTaskTap,
    this.onTaskLongPress,
    this.taskKey = _defaultTaskKey,
    this.onBulkComplete,
    this.onBulkCategoryChange,
    this.onDeleteTasks,
  });

  static String _defaultTaskKey(Task t) {
    final catId = t.taskCategory?.id ?? 'null';
    final catColor = t.taskCategory?.colour?.r ?? 'null';
    return '${t.id}_${catId}_$catColor';
  }

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final Set<int> _selectedTaskIds = {};
  bool _isBulkComplete = false;
  TaskCategory? _bulkSelectedCategory;
  OverlayEntry? _overlayEntry;

  void _toggleTaskSelection(int? taskId) {
    if (taskId == null) return;
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
      _updateToolbarPresets();
    });
  }

  void _updateToolbarPresets() {
    if (_selectedTaskIds.isEmpty) {
      _isBulkComplete = false;
      _bulkSelectedCategory = null;
    } else {
      final selectedTasks =
          widget.tasks.where((t) => _selectedTaskIds.contains(t.id));

      _isBulkComplete = selectedTasks.every((t) => t.isDone);

      final categories = selectedTasks.map((t) => t.taskCategory).toSet();
      _bulkSelectedCategory = categories.length == 1 ? categories.first : null;
    }

    _updateOverlay();
  }

  void _clearSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _isBulkComplete = false;
      _bulkSelectedCategory = null;
      _removeOverlay();
    });
  }

  void _handleBulkActions() {
    if (_isBulkComplete && widget.onBulkComplete != null) {
      widget.onBulkComplete!(_selectedTaskIds.toList(), _isBulkComplete);
    }
    if (_bulkSelectedCategory != null && widget.onBulkCategoryChange != null) {
      widget.onBulkCategoryChange!(
          _selectedTaskIds.toList(), _bulkSelectedCategory);
    }
    _clearSelection();
  }

  void _deleteSelected() {
    if (widget.onDeleteTasks != null) {
      widget.onDeleteTasks!(_selectedTaskIds.toList());
      _clearSelection();
    }
  }

  void _updateOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedTaskIds.isEmpty) {
        _removeOverlay();
        return;
      }

      if (_overlayEntry == null) {
        _overlayEntry = SelectionToolbarOverlay.show(
          context: context,
          overlay: SelectionToolbarOverlay(
            selectedCount: _selectedTaskIds.length,
            bulkSelectedCategory: _bulkSelectedCategory,
            onDeleteConfirmed: _deleteSelected,
            onClosePressed: _clearSelection,
            onConfirmPressed: _handleBulkActions,
            onBulkCompleteChanged: (v) =>
                setState(() => _isBulkComplete = v ?? false),
            onCategorySelected: (c) =>
                setState(() => _bulkSelectedCategory = c),
          ),
        );
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        print(widget.taskKey(task));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TaskCard(
            key: ValueKey(widget.taskKey(task)),
            task: task,
            isSelected: _selectedTaskIds.contains(task.id),
            isTappable: _selectedTaskIds.isEmpty,
            dateFormat: widget.dateFormat,
            circleCheckbox: widget.isCircleCheckbox,
            onCheckboxChanged: (_) => widget.onCheckboxChanged?.call(task),
            onTap: () {
              if (_selectedTaskIds.isNotEmpty) {
                _toggleTaskSelection(task.id);
              } else {
                widget.onTaskTap?.call(task);
              }
            },
            onLongPress: () => _toggleTaskSelection(task.id),
          ),
        );
      },
    );
  }
}
