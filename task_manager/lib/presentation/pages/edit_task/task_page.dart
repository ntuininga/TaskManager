import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/recurrence_ruleset.dart';
import 'package:task_manager/domain/models/recurring_task_details.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/category_dropdown.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/complete_task_button.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/date_field.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/description_field.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/recurrence_field.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/reminder_field.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/title_field.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  final VoidCallback? onSave;
  final bool isUpdate;

  const TaskPage({Key? key, this.task, this.isUpdate = false, this.onSave})
      : super(key: key);

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
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

  RecurrenceRuleset? recurrenceRuleset;
  bool isRecurrenceEnabled = false;
  bool isRecurringInstance = false;

  String? selectedFrequency;

  RecurringTaskDetails? recurringDetails;

  bool isEditing = false;
  final FocusNode descFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeFields();
    }
  }

  void _initializeFields() {
    //Task details initialization
    titleController.text = widget.task?.title ?? '';
    descController.text = widget.task?.description ?? '';
    if (widget.task?.date != null) {
      dateController.text = dateFormat.format(widget.task!.date!);
    }
    selectedCategory = widget.task?.taskCategory;
    selectedPriority = widget.task?.urgencyLevel ?? TaskPriority.none;
    selectedTime = widget.task?.time;

    //Recurrence initialization
    isRecurrenceEnabled = widget.task!.isRecurring;
    if (widget.task!.recurrenceRuleset != null) {
      selectedFrequency =
          widget.task!.recurrenceRuleset!.frequency!.toShortString();
    }
    isRecurringInstance = widget.task!.recurringInstanceId != null;

    //Time controller initialization
    if (selectedTime != null) {
      final hour = selectedTime!.hour.toString().padLeft(2, '0');
      final minute = selectedTime!.minute.toString().padLeft(2, '0');
      timeController.text = '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTitleField(
                    context: context,
                    controller: titleController,
                    priority: selectedPriority!,
                    onPriorityChanged: () {
                      setState(() {
                        selectedPriority = selectedPriority == TaskPriority.high
                            ? TaskPriority.none
                            : TaskPriority.high;
                      });
                    }),
                const SizedBox(height: 15),

                // Task Description Field
                DescriptionField(
                    controller: descController, focusNode: descFocusNode),
                const SizedBox(height: 30),

                // Category dropdown widget
                CategoryDropdown(
                    selectedCategory: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }),
                const SizedBox(height: 10),

                // Date Field Widget
                DateField(
                    controller: dateController,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {}),
                ReminderField(
                    controller: timeController,
                    selectedTime: selectedTime,
                    onTimeSelected: (time) {
                      setState(() {
                        selectedTime = time;
                        timeController.text = formatTime(time!); // Format time
                      });
                    }),

                RecurrenceField(
                    isRecurrenceEnabled: isRecurrenceEnabled,
                    onRecurrenceToggle: (value) {
                      setState(() {
                        isRecurrenceEnabled = value;
                      });
                    },
                    selectedFrequency: selectedFrequency,
                    onFrequencySelected: (frequency) {
                      setState(() {
                        selectedFrequency = frequency;
                      });
                    }),

                // if (isRecurrenceEnabled) _buildRecurrenceDetailsSection(),
                const SizedBox(height: 30),
                if (widget.task?.isDone == false)
                  CompleteTaskButton(task: widget.task!),
                const SizedBox(height: 30),
                if (widget.isUpdate) _buildCreationDateInfo(),
                if (widget.task?.isDone == true) _buildCompletionDateInfo()
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
      context.read<TasksBloc>().add(DeleteTask(
          taskId: widget.task!.id!,
          task: widget.task)); // Removed unnecessary `!`
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      setState(() => isDeletePressed = true);

      // Store the current context to avoid issues with delayed execution
      final currentContext = context;

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && isDeletePressed && currentContext == context) {
          setState(() => isDeletePressed = false);
        }
      });
    }
  }

  Widget _buildRecurrenceDetailsSection() {
    return const ExpansionTile(
      title: Text("Scheduled Dates"),
      children: [
        // if (widget.task != null && widget.task!.id != null)
        //   RecurringTaskDetailsWidget(taskId: widget.task!.id!)
      ],
    );
  }

  Widget _buildSaveButton() {
    return BlocListener<TasksBloc, TasksState>(
      listener: (context, state) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: ElevatedButton(
        onPressed: _saveTask,
        child: Text(widget.isUpdate ? "Update Task" : "Save Task"),
      ),
    );
  }

  void _saveTask() async {
    final parsedDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dateController.text, true)
        : null;

    if (parsedDate == null && selectedTime != null) {
      // Clear time if date is null for consistency
      selectedTime = null;
      timeController.clear();
    }

    if (isRecurrenceEnabled && selectedFrequency != null) {
      recurrenceRuleset = RecurrenceRuleset(
        frequency: FrequencyExtension.fromString(selectedFrequency!),
      );
    } else {
      recurrenceRuleset = null;
    }

    final newTask = Task(
        title: titleController.text,
        description: descController.text,
        taskCategory: selectedCategory,
        urgencyLevel: selectedPriority,
        date: parsedDate,
        time: selectedTime,
        isRecurring: isRecurrenceEnabled,
        recurrenceRuleset: recurrenceRuleset);

    if (widget.isUpdate) {
      _updateTask();
    } else {
      context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
    }
  }

  void _updateTask() async {
    final parsedDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dateController.text, true)
        : null;

    if (parsedDate == null && selectedTime != null) {
      // Clear time if date is null for consistency
      selectedTime = null;
      timeController.clear();
    }

    final updatedTask = widget.task!.copyWith(
        title: titleController.text,
        description: descController.text,
        taskCategory: selectedCategory,
        urgencyLevel: selectedPriority,
        date: parsedDate,
        time: selectedTime,
        isRecurring: isRecurrenceEnabled,
        recurrenceRuleset: recurrenceRuleset,
        copyNullValues: true);

    if (parsedDate == null) {
      updatedTask.date = null;
    }

    context.read<TasksBloc>().add(UpdateTask(taskToUpdate: updatedTask));
  }

  Widget _buildCreationDateInfo() {
    final creationDate = widget.task!.createdOn;
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
