import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  final Function()? onTap;

  const TaskCard({
    required this.task,
    required this.onCheckboxChanged,
    this.onTap,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showTaskDialog(
          context,
          title: task.title
        );
      },
      child: Card(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            border: Border(
              left: BorderSide(
                color: Colors.blue,
                width: 5.0
              )
            )
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: task.isDone, 
                    onChanged: onCheckboxChanged, 
                    shape: const CircleBorder()
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                  child: Text(task.title, style: const TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}