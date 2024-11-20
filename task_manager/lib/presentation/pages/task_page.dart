import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/core/utils/colour_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/Dialogs/date_picker.dart';
import 'package:task_manager/presentation/widgets/Dialogs/reminder_dialog.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';
import 'package:task_manager/presentation/widgets/task_input_field.dart';

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
  final TextEditingController timeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TaskCategory? selectedCategory;
  TaskPriority? selectedPriority = TaskPriority.none;
  bool isDeletePressed = false;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  int? notifyBeforeMinutes;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    titleController.text = widget.task!.title ?? '';
    descController.text = widget.task!.description ?? '';
    if (widget.task!.date != null) {
      dateController.text = dateFormat.format(widget.task!.date!);
    }
    selectedCategory = widget.task!.taskCategory;
    selectedPriority = widget.task!.urgencyLevel ?? TaskPriority.none;
    selectedTime = widget.task!.time;

    if (widget.task!.reminderDate != null) {
      reminderDateController.text =
          dateFormat.format(widget.task!.reminderDate!);
    }
    if (widget.task!.time != null) {
      timeController.text = _formatTime(widget.task!.time!);
    }
    if (widget.task!.notifyBeforeMinutes != null) {
      notifyBeforeMinutes = widget.task!.notifyBeforeMinutes;
    }
    print("INitial $notifyBeforeMinutes");
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour % 12;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hours == 0 ? 12 : hours}:$minutes $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleField(),
                const SizedBox(height: 30),
                // _buildCategoryAndPriority(),
                _buildDateField(
                    dateController, "Date", Icons.calendar_today_rounded),
                _buildReminderField(),
                const SizedBox(height: 30),
                if (widget.isUpdate) _buildCreationDateInfo(),
                if (widget.task != null && widget.task!.isDone)
                  _buildCompletionDateInfo()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSaveButton(),
    );
  }

  AppBar _buildAppBar() {
    final theme = Theme.of(context);
    final textColor = theme.dividerColor;

    return AppBar(
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
                  color: isDeletePressed ? Colors.red : textColor),
              onPressed: _handleDeleteTask,
            ),
          ),
      ],
    );
  }

  void _handleDeleteTask() {
    if (isDeletePressed) {
      context.read<TasksBloc>().add(DeleteTask(id: widget.task!.id!));
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
  }

  Widget _buildCategoryAndPriority() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BasicButton(
          onPressed: () async {
            var category = await showCategoriesDialog(context);
            if (category != null) {
              setState(() {
                selectedCategory = category; // Update state
                widget.task?.taskCategory = category; // Update task
              });
            }
          },
          text: selectedCategory?.title ?? "Category",
          textColor: selectedCategory?.colour ?? Theme.of(context).dividerColor,
          backgroundColor: selectedCategory?.colour != null
              ? lightenColor(selectedCategory!.colour!)
              : Theme.of(context).buttonTheme.colorScheme!.background,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            autofocus: true,
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            minLines: 3,
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                selectedPriority == TaskPriority.high
                    ? Icons.flag // Filled flag icon when urgent
                    : Icons.outlined_flag, // Outlined flag icon when not urgent
                color: selectedPriority == TaskPriority.high
                    ? Colors.red // Red color for high priority
                    : Theme.of(context)
                        .dividerColor, // Text color when not urgent
              ),
              onPressed: () {
                setState(() {
                  selectedPriority = selectedPriority == TaskPriority.high
                      ? TaskPriority.none
                      : TaskPriority.high;
                });
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                // Implement the category selection logic here
                TaskCategory? selected = await showCategoriesDialog(context);
                if (selected != null) {
                  setState(() {
                    selectedCategory = selected;
                  });
                }
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: selectedCategory?.colour ?? Colors.grey,
                child: Icon(
                  Icons.circle,
                  size: 16,
                  color: Colors.white, // Inner icon color
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return TaskInputField(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: label,
        ),
        onTap: () async {
          DateTime? pickedDate = await showCustomDatePicker(
            context,
            initialDate: selectedDate ?? DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text = dateFormat.format(pickedDate);
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty && selectedTime != null) {
            return 'Date cannot be empty if time is selected';
          }
          return null;
        },
      ),
    );
  }

  final Map<String, int> notifyBeforeOptions = {
    '0 minutes': 0,
    '5 minutes': 5,
    '15 minutes': 15,
    '30 minutes': 30,
    '1 hour': 60,
    '1 day': 1440, // 1440 minutes = 24 hours = 1 day
  };

  Widget _buildReminderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: timeController,
          decoration: const InputDecoration(
            icon: Icon(Icons.alarm),
            labelText: "Reminder & Time",
            border: InputBorder.none,
          ),
          readOnly: true,
          onTap: () async {
            await showReminderDialog(
              context,
              selectedTime: selectedTime,
              selectedDate: selectedDate,
              notifyBeforeMinutes: notifyBeforeMinutes,
              onReminderSet: (pickedTime, beforeMinutes) {
                setState(() {
                  selectedTime = pickedTime;
                  timeController.text = _formatTime(pickedTime!);
                  notifyBeforeMinutes = beforeMinutes;
                });
              },
            );
          },
        ),
        const SizedBox(height: 10),
        if (selectedTime != null) // Only show if a time is selected
          Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notify before:",
                        textAlign: TextAlign.start,
                      ),
                      DropdownButton<int>(
                        value: notifyBeforeMinutes, // Currently selected value
                        onChanged: (int? newValue) {
                          setState(() {
                            notifyBeforeMinutes = newValue!;
                          });
                        },
                        items: notifyBeforeOptions.entries
                            .map<DropdownMenuItem<int>>(
                          (MapEntry<String, int> entry) {
                            return DropdownMenuItem<int>(
                              value: entry.value,
                              child: Text(entry
                                  .key), // Display the string label (e.g., '5 minutes')
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (formKey.currentState?.validate() ?? false) {
          if (widget.isUpdate) {
            _updateTask();
          } else {
            _saveTask();
          }

          widget.onSave?.call();
          Navigator.of(context).pop();
        }
      },
      label: const Text('Save'),
      icon: const Icon(Icons.save),
    );
  }

  void _saveTask() async {
    final newTask = Task(
      title: titleController.text,
      description: descController.text,
      taskCategory: selectedCategory,
      urgencyLevel: selectedPriority,
      date: dateController.text.isNotEmpty
          ? DateTime.parse(dateController.text)
          : null,
      time: selectedTime,
      notifyBeforeMinutes: notifyBeforeMinutes ?? 0,
    );

    print(newTask.notifyBeforeMinutes);
    context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
  }

  void _updateTask() async {
    final updatedTask = widget.task!.copyWith(
      title: titleController.text,
      description: descController.text,
      taskCategory: selectedCategory,
      urgencyLevel: selectedPriority,
      date: dateController.text.isNotEmpty
          ? DateTime.parse(dateController.text)
          : null,
      time: selectedTime,
      notifyBeforeMinutes: notifyBeforeMinutes,
    );

    context.read<TasksBloc>().add(UpdateTask(taskToUpdate: updatedTask));
  }

  DateTime? _parseReminderDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return dateFormat.parse(dateText);
    } catch (e) {
      return null;
    }
  }

  Widget _buildCreationDateInfo() {
    final creationDate = widget.task!.createdOn!;
    return Text(
      "Created on: ${dateFormat.format(creationDate)}",
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildCompletionDateInfo() {
    final completionDate = widget.task!.completedDate;
    if (completionDate == null) {
      return const SizedBox(); // Return an empty widget if no completion date
    }
    return Text(
      "Completed on: ${dateFormat.format(completionDate)}",
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

}
