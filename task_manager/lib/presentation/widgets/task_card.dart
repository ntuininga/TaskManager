import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/pages/edit_task/task_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?)? onCheckboxChanged;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isTappable;
  final bool isSelected;
  final String? dateFormat;
  final bool circleCheckbox;
  final Function(bool)? onSelect;

  const TaskCard({
    required this.task,
    this.onCheckboxChanged,
    this.onTap,
    this.onLongPress,
    this.isTappable = true,
    this.isSelected = false,
    this.dateFormat,
    this.circleCheckbox = true,
    this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(dateFormat ?? 'yyyy-MM-dd');

    return GestureDetector(
      onTap: () {
        if (task.recurringInstanceId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This is a generated Task and cannot be edited'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (isSelected) {
          onSelect?.call(!isSelected);
        } else if (isTappable) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskPage(task: task, isUpdate: true),
            ),
          );
        } else {
          onTap?.call();
        }
      },
      onLongPress: isTappable ? onLongPress : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(31, 194, 194, 194),
          borderRadius: BorderRadius.circular(5.0),
          border: isSelected
              ? Border.all(color: Colors.blue)
              : Border(
                  left: BorderSide(
                    color: task.isDone
                        ? Colors.grey
                        : task.taskCategory?.colour ?? Colors.grey,
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
                        value: task.isDone,
                        onChanged: onCheckboxChanged,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(circleCheckbox ? 20 : 2)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        task.title ?? 'Untitled Task',
                        style: TextStyle(
                          fontSize: 15,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (task.recurringInstanceId != null)
                    const Icon(Icons.repeat, color: Colors.green),
                  if (task.date != null &&
                      task.urgencyLevel != TaskPriority.high)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        formattedDate.format(task.date!),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  else if (task.urgencyLevel == TaskPriority.high)
                    const Icon(Icons.flag, color: Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
