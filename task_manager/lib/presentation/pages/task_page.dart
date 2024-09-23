import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/utils/colour_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/Dialogs/date_picker.dart';
import 'package:task_manager/presentation/widgets/buttons/basic_button.dart';
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
  final TextEditingController reminderTimeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TaskCategory? selectedCategory;
  TaskPriority? selectedPriority = TaskPriority.none;
  bool isDeletePressed = false;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeFields();
      selectedCategory = widget.task!.taskCategory;
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
      if (widget.task!.reminderTime != null) {
        reminderTimeController.text = _formatTime(widget.task!.reminderTime!);
      }
    }
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
                _buildCategoryAndPriority(),
                // _buildCategoryField(),
                // _buildUrgencyField(),
                _buildDateField(
                    dateController, "Date", Icons.calendar_today_rounded),
                _buildReminderField(),
                const SizedBox(height: 30),
                if (widget.isUpdate) _buildCreationDateInfo(),
                if (widget.task!.isDone) _buildCompletionDateInfo(),
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
      const SizedBox(width: 50),
      BasicButton(
        text: "Urgent",
        textColor: selectedPriority != TaskPriority.none
            ? Theme.of(context).primaryColor
            : Theme.of(context).dividerColor,
        icon: Icons.flag,
        onPressed: () {
          setState(() {
            selectedPriority = selectedPriority == TaskPriority.none
                ? TaskPriority.high
                : TaskPriority.none;
          });
        },
      ),
    ],
  );
}

  Widget _buildTitleField() {
    return TextFormField(
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
    );
  }

  Widget _buildCategoryField() {
    return TaskInputField(
      child: CategorySelector(
        onCategorySelected: (category) {},
      ),
    );
  }

  Widget _buildUrgencyField() {
    return TaskInputField(
      child: CategorySelector(
        onCategorySelected: (category) {},
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon,
      {double borderWidth = 1.0}) {
    return TaskInputField(
      borderWidth: borderWidth,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: Theme.of(context).dividerColor),
          border: InputBorder.none,
          labelText: label,
        ),
        onTap: () async {
          DateTime? pickedDate = await showCustomDatePicker(context,
              initialDate: widget.task?.date ?? DateTime.now());
          if (pickedDate != null) {
            controller.text = dateFormat.format(pickedDate);
          } else {
            controller.text = "";
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty && widget.task!.time != null) {
            return 'Date cannot be empty if time is selected';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReminderField() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateField(
              reminderDateController, "Reminder", Icons.notifications,
              borderWidth: 0),
          if (reminderDateController.text.isNotEmpty)
            Row(
              children: [
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: reminderTimeController,
                    decoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      icon: const Icon(Icons.alarm),
                      labelText: "Time",
                      border:
                          InputBorder.none, // Remove border for the time field
                    ),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime:
                            widget.task?.reminderTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        reminderTimeController.text = _formatTime(pickedTime);
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCreationDateInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
          "Created On: ${widget.task?.createdOn != null ? dateFormat.format(widget.task!.createdOn) : ''}"),
    );
  }

  Widget _buildCompletionDateInfo() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
            "Completed On: ${widget.task?.completedDate != null ? dateFormat.format(widget.task!.completedDate!) : ""}"),
      ),
    );
  }

  FloatingActionButton _buildSaveButton() {
    return FloatingActionButton(
      onPressed: _handleSave,
      child: const Icon(Icons.save),
    );
  }

  void _handleSave() async {
    if (formKey.currentState!.validate()) {
      if (!widget.isUpdate) {
        Task newTask = Task(
          title: titleController.text,
          description: descController.text,
          date: dateController.text.isNotEmpty
              ? DateTime.parse(dateController.text)
              : null,
          taskCategory: selectedCategory,
          urgencyLevel: selectedPriority,
          reminder: selectedTime != null,
          reminderDate: reminderDateController.text.isNotEmpty
              ? DateTime.parse(reminderDateController.text)
              : null,
          reminderTime: selectedTime,
          time: selectedTime,
        );

        context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
        widget.onSave?.call();
      } else {
        widget.task!.title = titleController.text;
        widget.task!.description = descController.text;
        widget.task!.date = dateController.text.isNotEmpty
            ? DateTime.parse(dateController.text)
            : null;
        widget.task!.taskCategory = selectedCategory;
        widget.task!.urgencyLevel = selectedPriority;
        widget.task!.reminder = selectedTime != null;
        widget.task!.reminderDate = reminderDateController.text.isNotEmpty
            ? DateTime.parse(reminderDateController.text)
            : null;
        widget.task!.reminderTime = selectedTime;

        context.read<TasksBloc>().add(UpdateTask(taskToUpdate: widget.task!));
      }
      Navigator.of(context).pop();
    }
  }
}

class TaskInputField extends StatelessWidget {
  final Widget child;
  final double? borderWidth;

  const TaskInputField({Key? key, required this.child, this.borderWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: borderWidth ?? 1,
              color: borderWidth == 0
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child),
        ],
      ),
    );
  }
}
