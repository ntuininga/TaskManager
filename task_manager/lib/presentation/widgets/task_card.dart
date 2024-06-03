import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  
  TaskCategory? category;

  void refreshTaskCard() async {
    var cardCategory = await taskRepository.getCategoryById(widget.task.taskCategoryId!);
    print(cardCategory.id);
    setState(() {
      category = cardCategory;
    });
  }

  @override
  void initState(){
    refreshTaskCard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showTaskDialog(
          context,
          task: widget.task,
          onTaskSubmit: () {
            refreshTaskCard();
          },
          isUpdate: true
        );
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            border: Border(
              left: BorderSide(
                color: category == null ? Colors.grey : 
                        category!.colour == null ? Colors.grey : category!.colour!,
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
                    value: widget.task.isDone, 
                    onChanged: widget.onCheckboxChanged, 
                    shape: const CircleBorder()
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                  child: Text(widget.task.title, style: const TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}