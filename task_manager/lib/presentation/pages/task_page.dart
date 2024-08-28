import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  final bool isUpdate;

  const TaskPage({Key? key, this.task, this.isUpdate = false})
      : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController dateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? selectedCategoryId;
  TaskPriority? selectedPriority = TaskPriority.none;
  bool isDeletePressed = false; // Track the first press on delete button

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title ?? '';
      descController.text = widget.task!.description ?? '';
      if (widget.task!.date != null) {
        dateController.text = dateFormat.format(widget.task!.date!);
      }
      selectedCategoryId = widget.task!.taskCategoryId;
      selectedPriority = widget.task!.urgencyLevel ?? TaskPriority.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.isUpdate ? 'Update Task' : 'New Task'),
        actions: [
          if (widget.isUpdate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                icon: Icon(Icons.delete,
                    color: isDeletePressed ? Colors.red : Colors.black),
                onPressed: () {
                  if (isDeletePressed) {
                    context
                        .read<TasksBloc>()
                        .add(DeleteTask(id: widget.task!.id!));
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      isDeletePressed = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted && isDeletePressed) {
                        setState(() {
                          isDeletePressed = false;
                        });
                      }
                    });
                  }
                },
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategorySelector(
                      initialCategory: widget.task?.taskCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedCategoryId = category.id;
                        });
                      },
                    ),
                    BasicButton(
                      text: "Urgent", 
                      icon: Icons.flag,
                      onPressed: (){
                      print("Test success");
                    }),
                    IconButton(
                        color: widget.task!.urgencyLevel == TaskPriority.high
                            ? Colors.red
                            : Colors.black,
                        onPressed: () {
                          setState(() {
                            if (widget.task!.urgencyLevel ==
                                TaskPriority.high) {
                              widget.task!.urgencyLevel = TaskPriority.none;
                            } else {
                              widget.task!.urgencyLevel = TaskPriority.high;
                            }
                          });
                        },
                        icon: widget.task!.urgencyLevel == TaskPriority.high
                            ? const Icon(Icons.flag)
                            : const Icon(Icons.outlined_flag))
                  ],
                ),
                TextFormField(
                  autofocus: true,
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Description"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextFormField(
                    controller: descController,
                    minLines: 5,
                    maxLines: 5,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 1)
                  )),
                  child: TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today_rounded),
                        border: InputBorder.none,
                        labelText: "Date"),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000));
                      if (pickedDate != null) {
                        dateController.text = dateFormat.format(pickedDate);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                if (widget.isUpdate)
                  Text("Created On: ${widget.task?.createdOn ?? ''}"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (!widget.isUpdate) {
              Task newTask = Task(
                title: titleController.text,
                description: descController.text,
                date: DateTime.parse(dateController.text),
                taskCategoryId: selectedCategoryId,
                urgencyLevel: widget.task!.urgencyLevel,
              );
              context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
            } else {
              widget.task!.title = titleController.text;
              widget.task!.description = descController.text;
              widget.task!.date = DateTime.parse(dateController.text);
              widget.task!.taskCategoryId = selectedCategoryId;

              context
                  .read<TasksBloc>()
                  .add(UpdateTask(taskToUpdate: widget.task!));
            }
            Navigator.of(context).pop();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
