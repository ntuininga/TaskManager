import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

Future<void> showTaskDialog(BuildContext context,
    {Task? task, Function()? onTaskSubmit, bool isUpdate = false}) async {
  final TextEditingController titleController =
      TextEditingController(text: task?.title ?? '');
  final TextEditingController descController =
      TextEditingController(text: task?.description ?? '');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController dateController = TextEditingController(
      text: task?.date != null ? dateFormat.format(task!.date!) : '');
  int? selectedCategoryId = task?.taskCategoryId ?? 0;
  TaskPriority? selectedPriority = task?.urgencyLevel ?? TaskPriority.none; // Default to none

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isUpdate ? 'Update Task' : 'New Task'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    TextFormField(
                      controller: descController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    CategorySelector(
                        initialCategory: task!.taskCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategoryId = category.id;
                          });
                        }),
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today_rounded),
                          labelText: "Date"),
                      onTap: () async {
                        FocusScope.of(context)
                            .requestFocus(FocusNode()); // Close the keyboard
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
                        // Add additional validation if needed
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Task Priority"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<TaskPriority>(
                          value: TaskPriority.high,
                          groupValue: selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value;
                            });
                          },
                        ),
                        const Text('High'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (isUpdate) Text("Created On: ${task.createdOn}"),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (!isUpdate) {
                      Task newTask = Task(
                        title: titleController.text,
                        description: descController.text,
                        date: DateTime.parse(dateController.text),
                        taskCategoryId: selectedCategoryId,
                        urgencyLevel: selectedPriority,
                      );
                      context
                          .read<TasksBloc>()
                          .add(AddTask(taskToAdd: newTask));
                    } else {
                      // Update Task
                      task.title = titleController.text;
                      task.description = descController.text;
                      task.date = DateTime.parse(dateController.text);
                      task.taskCategoryId = selectedCategoryId;
                      task.urgencyLevel = selectedPriority;

                      context
                          .read<TasksBloc>()
                          .add(UpdateTask(taskToUpdate: task));
                    }
                    onTaskSubmit?.call();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
