import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/task_page.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(bool?)? onCheckboxChanged;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isTappable;
  final bool isSelected;
  final Function(bool)? onSelect;

  const TaskCard({
    required this.task,
    this.onCheckboxChanged,
    this.onTap,
    this.onLongPress,
    this.isTappable = true,
    this.isSelected = false,
    this.onSelect,
    super.key,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  void _showTaskPageOverlay(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => TaskPage(task: task, isUpdate: true),
      ),
    );
  }

  void _handleTaskCompletion(bool isDone) {
    final updatedTask = widget.task.copyWith(isDone: isDone);
    widget.onCheckboxChanged?.call(isDone); // Only call if non-null
    context.read<TasksBloc>().add(CompleteTask(taskToComplete: updatedTask));
  }

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(31, 194, 194, 194),
        borderRadius: BorderRadius.circular(5.0),
        border: widget.isSelected
            ? Border.all(color: Colors.blue)
            : Border(
                left: BorderSide(
                  color: widget.task.isDone
                      ? Colors.grey
                      : widget.task.taskCategory?.colour ?? Colors.grey,
                  width: 5.0,
                ),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Checkbox(
                      value: widget.task.isDone,
                      onChanged: (value) {
                        if (value != null) {
                          _handleTaskCompletion(value);
                        }
                      },
                      shape: const CircleBorder(),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.task.title ?? 'Untitled Task',
                      style: TextStyle(
                        fontSize: 15,
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Check if the task is recurring
            if (widget.task.recurrenceType != null)
              const Icon(Icons.loop, color: Colors.green) // Icon for recurring tasks
            else if (widget.task.date != null &&
                widget.task.urgencyLevel != TaskPriority.high)
              Text(
                dateFormat.format(widget.task.date!),
                style: const TextStyle(color: Colors.grey),
              )
            else if (widget.task.urgencyLevel == TaskPriority.high)
              const Icon(Icons.flag, color: Colors.red),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        if (widget.isSelected && widget.onSelect != null) {
          widget.onSelect?.call(!widget.isSelected);
        } else if (widget.isTappable) {
          _showTaskPageOverlay(context, task: widget.task);
        } else {
          widget.onTap?.call();
        }
      },
      onLongPress: widget.isTappable ? widget.onLongPress : null,
      child: card,
    );
  }
}
