import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'task_card.dart'; // adjust import path
import 'package:task_manager/domain/models/task.dart'; // adjust import path

typedef TaskKey = String Function(Task task);

class AnimatedTaskList extends StatefulWidget {
  final List<Task> tasks;
  final String dateFormat;
  final bool isCircleCheckbox;
  final Set<int> selectedTaskIds;
  final bool isSelectionMode;
  final void Function(Task task)? onCheckboxChanged;
  final void Function(Task task)? onTaskTap;
  final void Function(Task task)? onTaskLongPress;

  /// Task key extractor (default: by ID)
  final TaskKey taskKey;

  const AnimatedTaskList({
    super.key,
    required this.tasks,
    required this.dateFormat,
    required this.isCircleCheckbox,
    required this.selectedTaskIds,
    required this.isSelectionMode,
    this.onCheckboxChanged,
    this.onTaskTap,
    this.onTaskLongPress,
    this.taskKey = _defaultTaskKey,
  });

  static String _defaultTaskKey(Task t) => t.id?.toString() ?? 'id:null';

  @override
  State<AnimatedTaskList> createState() => _AnimatedTaskListState();
}

class _AnimatedTaskListState extends State<AnimatedTaskList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<Task> _taskList;

  @override
  void initState() {
    super.initState();
    _taskList = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant AnimatedTaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList(oldWidget.tasks, widget.tasks);
  }

  void _updateList(List<Task> oldTasks, List<Task> newTasks) {
    final oldKeys = oldTasks.map(widget.taskKey).toList();
    final newKeys = newTasks.map(widget.taskKey).toList();

    // 1. Remove tasks not in new list
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

    // 2. Handle reordering (same set, different order)
    final sameSet =
        _taskList.length == newTasks.length &&
        _taskList.map(widget.taskKey).toSet().containsAll(newKeys);

    final isReordered = sameSet && !listEquals(oldKeys, newKeys);

    if (isReordered) {
      _taskList
        ..clear()
        ..addAll(newTasks);
      setState(() {}); // force rebuild (no remove/insert flicker)
      return;
    }

    // 3. Insert/update tasks
    for (int i = 0; i < newTasks.length; i++) {
      final newTask = newTasks[i];
      final newKey = widget.taskKey(newTask);
      final index = _taskList.indexWhere((t) => widget.taskKey(t) == newKey);

      if (index == -1) {
        // Insert new
        _taskList.insert(i, newTask);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 200),
        );
      } else {
        // Update existing
        _taskList[index] = newTask;
      }
    }
  }

  Widget _buildRemovedTask(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Opacity(
        opacity: 0.5,
        child: TaskCard(
          task: task,
          isSelected: widget.selectedTaskIds.contains(task.id),
          isTappable: !widget.isSelectionMode,
          dateFormat: widget.dateFormat,
          circleCheckbox: widget.isCircleCheckbox,
        ),
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context, int index, Animation<double> animation) {
    final task = _taskList[index];
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TaskCard(
          task: task,
          isSelected: widget.selectedTaskIds.contains(task.id),
          isTappable: !widget.isSelectionMode,
          dateFormat: widget.dateFormat,
          circleCheckbox: widget.isCircleCheckbox,
          onCheckboxChanged: (_) => widget.onCheckboxChanged?.call(task),
          onTap: () => widget.onTaskTap?.call(task),
          onLongPress: () => widget.onTaskLongPress?.call(task),
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
}
