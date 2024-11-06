import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/task_page.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isTappable;
  final bool isSelected;
  final Function(bool)? onSelect;

  const TaskCard({
    required this.task,
    required this.onCheckboxChanged,
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
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  bool isDeleteConfirmation = false;

  void resetDeleteConfirmation() {
    setState(() {
      isDeleteConfirmation = false;
    });
  }

  void showTaskPageOverlay(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            TaskPage(task: task, isUpdate: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(31, 194, 194, 194),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
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
                        final updatedTask =
                            widget.task.copyWith(isDone: value!);
                        context
                            .read<TasksBloc>()
                            .add(UpdateTask(taskToUpdate: updatedTask));
                        widget.onCheckboxChanged(
                            value); // Notify parent if needed
                      },
                      shape: const CircleBorder(),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.task.title ?? '',
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
            if (widget.task.date != null && widget.task.urgencyLevel != TaskPriority.high)
              Text(
                dateFormat.format(widget.task.date!),
                style: const TextStyle(color: Colors.grey),
              ),
            if (widget.task.urgencyLevel == TaskPriority.high)
              const Icon(Icons.flag, color: Colors.red),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null){
          widget.onTap!();  
        }
        
        if (widget.isSelected) {
          widget.onSelect?.call(!widget.isSelected); // Toggle selection
        } 
        if (widget.isTappable) {
          showTaskPageOverlay(context, task: widget.task);
        }
      },
      onLongPress: widget.isTappable ? widget.onLongPress : null,
      child: card,
    );
  }
}
