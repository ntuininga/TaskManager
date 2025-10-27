import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'task_card.dart'; // adjust import path
import 'selection_toolbar_overlay.dart'; // our overlay widget

typedef TaskKey = String Function(Task task);

class AnimatedTaskList extends StatefulWidget {
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

  const AnimatedTaskList({
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

  static String _defaultTaskKey(Task t) => t.id?.toString() ?? 'id:null';

  @override
  State<AnimatedTaskList> createState() => _AnimatedTaskListState();
}

class _AnimatedTaskListState extends State<AnimatedTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<Task> _taskList;
  final Set<int> _selectedTaskIds = {};
  bool _isDeletePressed = false;
  bool _isBulkComplete = false;
  TaskCategory? _bulkSelectedCategory;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _taskList = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant AnimatedTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList(oldWidget.tasks, widget.tasks);
    _updateOverlay();
  }

  void _updateList(List<Task> oldTasks, List<Task> newTasks) {
    final oldKeys = oldTasks.map(widget.taskKey).toList();
    final newKeys = newTasks.map(widget.taskKey).toList();

    // Remove old tasks
    for (int i = oldTasks.length - 1; i >= 0; i--) {
      final task = oldTasks[i];
      if (!newKeys.contains(widget.taskKey(task))) {
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildRemovedTask(task, animation),
          duration: const Duration(milliseconds: 200),
        );
        _taskList.removeAt(i);
      }
    }

    // Reordering
    final sameSet =
        _taskList.length == newTasks.length &&
        _taskList.map(widget.taskKey).toSet().containsAll(newKeys);
    final isReordered = sameSet && !listEquals(oldKeys, newKeys);

    if (isReordered) {
      _taskList
        ..clear()
        ..addAll(newTasks);
      setState(() {});
      return;
    }

    // Insert/update tasks
    for (int i = 0; i < newTasks.length; i++) {
      final newTask = newTasks[i];
      final newKey = widget.taskKey(newTask);
      final index = _taskList.indexWhere((t) => widget.taskKey(t) == newKey);

      if (index == -1) {
        _taskList.insert(i, newTask);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 200),
        );
      } else {
        _taskList[index] = newTask;
      }
    }
  }

void _toggleTaskSelection(int? taskId) {
  if (taskId == null) return;

  setState(() {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }

    _updateToolbarPresets(); // update bulk complete & category based on selection
  });
}

void _updateToolbarPresets() {
  if (_selectedTaskIds.isEmpty) {
    _isBulkComplete = false;
    _bulkSelectedCategory = null;
  } else {
    final selectedTasks = _taskList.where((t) => _selectedTaskIds.contains(t.id));

    // Bulk complete: true only if all selected tasks are complete
    _isBulkComplete = selectedTasks.every((t) => t.isDone);

    // Bulk category: only set if all selected tasks have the same category
    final categories = selectedTasks.map((t) => t.taskCategory).toSet();
    _bulkSelectedCategory = categories.length == 1 ? categories.first : null;
  }

  _updateOverlay(); // rebuild toolbar overlay with updated presets
}



  void _clearSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _isDeletePressed = false;
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
      widget.onBulkCategoryChange!(_selectedTaskIds.toList(), _bulkSelectedCategory);
    }
    _clearSelection();
  }

// In AnimatedTaskList
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
          onBulkCompleteChanged: (v) => setState(() => _isBulkComplete = v ?? false),
          onCategorySelected: (c) => setState(() => _bulkSelectedCategory = c),
        ),
      );
    } else {
      // do not rebuild overlay fully
      _overlayEntry!.markNeedsBuild();
    }
  });
}


  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildRemovedTask(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Opacity(
        opacity: 0.5,
        child: TaskCard(
          task: task,
          isSelected: _selectedTaskIds.contains(task.id),
          isTappable: _selectedTaskIds.isEmpty,
          dateFormat: widget.dateFormat,
          circleCheckbox: widget.isCircleCheckbox,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, int index, Animation<double> animation) {
    final task = _taskList[index];
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TaskCard(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      physics: const BouncingScrollPhysics(),
      initialItemCount: _taskList.length,
      itemBuilder: _buildTaskCard,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
