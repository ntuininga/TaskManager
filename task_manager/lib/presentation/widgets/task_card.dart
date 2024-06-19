import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  final Function()? onTap;
  final bool isTappable;

  const TaskCard({
    required this.task,
    required this.onCheckboxChanged,
    this.onTap,
    this.isTappable = true,
    super.key,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  TaskCategory? category;
  bool isDeleteConfirmation = false;

  void refreshTaskCard() async {
    var cardCategory =
        await taskRepository.getCategoryById(widget.task.taskCategoryId!);
    setState(() {
      category = cardCategory;
    });
  }

  @override
  void initState() {
    refreshTaskCard();
    super.initState();
  }

  void resetDeleteConfirmation() {
    setState(() {
      isDeleteConfirmation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          border: Border(
            left: BorderSide(
              color: widget.task.isDone
                  ? Colors.grey
                  : category == null
                      ? Colors.grey
                      : category!.colour ?? Colors.grey,
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
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        value: widget.task.isDone,
                        onChanged: (value) {
                          Task originalTask = widget.task;
                          var taskWithUpdate =
                              originalTask.copyWith(isDone: value);
                          context
                              .read<TasksBloc>()
                              .add(UpdateTask(taskToUpdate: taskWithUpdate));
                        },
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        widget.task.title,
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
              IconButton(
                onPressed: () {
                  if (isDeleteConfirmation) {
                    context
                        .read<TasksBloc>()
                        .add(DeleteTask(id: widget.task.id!));
                  } else {
                    setState(() {
                      isDeleteConfirmation = true;
                    });
                  }
                },
                icon: const Icon(Icons.delete),
                color: isDeleteConfirmation ? Colors.red : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        if (isDeleteConfirmation) {
          resetDeleteConfirmation();
        }
      },
      child: widget.isTappable
          ? GestureDetector(
              onTap: () {
                showTaskDialog(
                  context,
                  task: widget.task,
                  onTaskSubmit: () {
                    refreshTaskCard();
                  },
                  isUpdate: true,
                );
              },
              child: card,
            )
          : card,
    );
  }
}
