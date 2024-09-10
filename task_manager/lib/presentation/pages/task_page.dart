import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/date_picker.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';
import 'package:task_manager/presentation/widgets/buttons/time_button.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  final VoidCallback? onSave;
  final bool isUpdate;

  const TaskPage({Key? key, this.task, this.isUpdate = false, this.onSave})
      : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController dateController = TextEditingController();
  final TextEditingController reminderDateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? selectedCategoryId;
  TaskPriority? selectedPriority = TaskPriority.none;
  bool isDeletePressed = false;
  TimeOfDay? selectedTime;
  TimeOfDay? selectedReminderTime;

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
      selectedTime = widget.task!.time;

      if (widget.task!.reminderDate != null) {
        reminderDateController.text =
            dateFormat.format(widget.task!.reminderDate!);
      }
      selectedReminderTime = widget.task!.reminderTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: isDeletePressed
                        ? Colors.red
                        : theme.textTheme.labelLarge!.color),
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
                        textColor: selectedPriority != TaskPriority.none
                            ? theme.primaryColor
                            : null,
                        icon: Icons.flag,
                        onPressed: () {
                          setState(() {
                            selectedPriority =
                                selectedPriority == TaskPriority.none
                                    ? TaskPriority.high
                                    : TaskPriority.none;
                          });
                        }),
                  ],
                ),
                TextFormField(
                  autofocus: true,
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  minLines: 1,
                  maxLines: null,
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
                const SizedBox(height: 30),
                Container(
                  decoration: const BoxDecoration(
                      border:
                          Border.symmetric(horizontal: BorderSide(width: 1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date & Time",
                        style: TextStyle(color: Theme.of(context).primaryColor)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                                controller: dateController,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.calendar_today_rounded),
                                    border: InputBorder.none,
                                    labelText: "Date"),
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showCustomDatePicker(
                                          context,
                                          initialDate: widget.task?.date ??
                                              DateTime.now());

                                  if (pickedDate != null) {
                                    dateController.text =
                                        dateFormat.format(pickedDate);
                                  } else {
                                    dateController.text = "";
                                  }
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty &&
                                          widget.task!.time != null) {
                                    return 'Date cannot be empty if time is selected';
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          TimeButton(
                              title: selectedTime?.format(context),
                              onPressed: (time) {
                                setState(() {
                                  selectedTime = time;
                                });
                              })
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: const BoxDecoration(
                      border:
                          Border.symmetric(horizontal: BorderSide(width: 1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reminder",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                                controller: reminderDateController,
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.notifications),
                                    border: InputBorder.none,
                                    labelText: "Date"),
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showCustomDatePicker(
                                          context,
                                          initialDate: widget.task?.date ??
                                              DateTime.now());

                                  if (pickedDate != null) {
                                    reminderDateController.text =
                                        dateFormat.format(pickedDate);
                                  } else {
                                    reminderDateController.text = "";
                                  }
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty &&
                                          widget.task!.reminder == true) {
                                    return 'To set the reminder, please enter a date';
                                  } else {
                                    return null;
                                  }
                                }),
                          ),
                          TimeButton(
                            title: selectedReminderTime?.format(context),
                            onPressed: (time) {
                              setState(() {
                                selectedReminderTime = time;
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (widget.isUpdate)
                  Align(
                      alignment: Alignment.bottomCenter,
                      child:
                          Text("Created On: ${widget.task?.createdOn ?? ''}")),
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
                date: dateController.text.isNotEmpty
                    ? DateTime.parse(dateController.text)
                    : null,
                taskCategoryId: selectedCategoryId,
                urgencyLevel: selectedPriority,
                reminder: selectedTime != null,
                reminderDate: reminderDateController.text.isNotEmpty
                    ? DateTime.parse(reminderDateController.text)
                    : null,
                reminderTime: selectedReminderTime,
                time: selectedTime,
              );

              context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
              if (widget.onSave != null) {
                widget.onSave!();
              }
            } else {
              widget.task!.title = titleController.text;
              widget.task!.description = descController.text;
              widget.task!.date = dateController.text.isNotEmpty
                  ? DateTime.parse(dateController.text)
                  : null;
              widget.task!.taskCategoryId = selectedCategoryId;
              widget.task!.urgencyLevel = selectedPriority;
              widget.task!.reminder = selectedTime != null;
              widget.task!.reminderDate = reminderDateController.text.isNotEmpty
                  ? DateTime.parse(reminderDateController.text)
                  : null;
              widget.task!.reminderTime = selectedReminderTime;
              widget.task!.time = selectedTime;

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
