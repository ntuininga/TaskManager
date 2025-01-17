import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/widgets/Dialogs/date_picker.dart';
import 'package:task_manager/presentation/widgets/task_input_field.dart';

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
  RecurrenceType? selectedRecurrenceType;
  bool isDeletePressed = false;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  int? notifyBeforeMinutes;
  bool isRecurrenceEnabled = false;

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

    selectedRecurrenceType = widget.task?.recurrenceType;
    isRecurrenceEnabled = selectedRecurrenceType != null;
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleField(),
                const SizedBox(height: 15),
                _buildDescriptionField(),
                const SizedBox(height: 30),
                _buildCategoryDropdown(context),
                const SizedBox(height: 10),
                _buildDateField(
                    dateController, "Date", Icons.calendar_today_rounded),
                _buildReminderField(),
                _buildRecurrenceTypeField(context),
                const SizedBox(height: 30),
                if (!widget.task!.isDone) _buildCompleteField(),
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

  Widget _buildCompleteField() {
    Task completedTask = widget.task!.copyWith(isDone: true);

    return Align(
        alignment: Alignment.bottomCenter,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
            onPressed: () {
              context
                  .read<TasksBloc>()
                  .add(CompleteTask(taskToComplete: completedTask));
              Navigator.of(context).pop();
            },
            child: const Text("Complete Task")));
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
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    final theme = Theme.of(context);
    final textColor = theme.dividerColor;

    if (isEditing || descController.text.isNotEmpty) {
      return Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && descController.text.isEmpty) {
            setState(() {
              isEditing = false;
            });
          }
        },
        child: TextField(
          autofocus: true,
          controller: descController,
          focusNode: descFocusNode,
          decoration: const InputDecoration(
            label: Text("Description"),
            hintText: 'Enter description...',
            border: OutlineInputBorder(),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {
            setState(() {
              isEditing = true;
            });
            Future.delayed(Duration.zero, () {
              descFocusNode.requestFocus();
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Ensures the button fits its content
            children: [
              Icon(Icons.notes_rounded, size: 24, color: textColor),
              const SizedBox(width: 4), // Space between icon and text
              Text(
                "Description",
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return BlocBuilder<TaskCategoriesBloc, TaskCategoriesState>(
      builder: (context, state) {
        if (state is LoadingGetTaskCategoriesState) {
          return const CircularProgressIndicator();
        } else if (state is SuccessGetTaskCategoriesState) {
          final categories = state.allCategories.toSet().toList();

          if (categories.isEmpty) {
            return const Text("No categories available");
          }

          // Ensure selectedCategory is valid
          if (selectedCategory != null &&
              !categories.contains(selectedCategory)) {
            selectedCategory = null; // Reset to null if not valid
          }

          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withOpacity(0.95),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<TaskCategory>(
                value: selectedCategory,
                hint: const Text('Select a category'),
                isExpanded: false,
                underline: const SizedBox(), // Removes the underline
                onChanged: (TaskCategory? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: _getCategoryDropdownItems(categories),
                dropdownColor: Theme.of(context).cardColor,
              ),
            ),
          );
        } else if (state is NoTaskCategoriesState) {
          return const Text("No categories available");
        } else if (state is TaskCategoryErrorState) {
          return Text("Error: ${state.errorMsg}");
        } else {
          return const SizedBox();
        }
      },
    );
  }

  List<DropdownMenuItem<TaskCategory>> _getCategoryDropdownItems(
      List<TaskCategory> categories) {
    return categories.map((category) {
      return DropdownMenuItem<TaskCategory>(
        value: category,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: category.colour ?? Colors.grey,
              radius: 8.0,
            ),
            const SizedBox(width: 10),
            Text(category.title ?? 'Unnamed Category'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDateField(
      TextEditingController controller, String label, IconData icon) {
    return TaskInputField(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            icon: Icon(icon), labelText: label, border: InputBorder.none),
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
          } else {
            setState(() {
              selectedDate = null;
              controller.clear(); // Clear the date field
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (selectedTime != null) {
              return 'Date cannot be empty if time is selected';
            }
            if (selectedRecurrenceType != null) {
              return 'Date cannot be empty if task is set as recurring';
            }
            return null; // Valid if both date and time are empty
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
            labelText: "Reminder Time", // Updated label
            border: InputBorder.none,
          ),
          readOnly: true,
          onTap: () async {
            // Show the time picker dialog
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );

            if (pickedTime != null) {
              setState(() {
                selectedTime = pickedTime;
                timeController.text = _formatTime(
                    pickedTime); // Format the time and set it in the controller
              });
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Add a widget to allow the user to select the recurrence type
  Widget _buildRecurrenceTypeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recurring",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: isRecurrenceEnabled,
              onChanged: (bool value) {
                setState(() {
                  isRecurrenceEnabled = value;
                  if (!isRecurrenceEnabled) {
                    selectedRecurrenceType = null; // Reset the dropdown value
                  }
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHigh
                          .withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: DropdownButton<RecurrenceType>(
                    value: selectedRecurrenceType,
                    hint: const Text("Select Recurrence Type"),
                    isExpanded: true,
                    underline: const SizedBox(), // Removes the underline
                    onChanged: isRecurrenceEnabled
                        ? (RecurrenceType? newValue) {
                            setState(() {
                              selectedRecurrenceType = newValue;
                            });
                          }
                        : null, // Disable dropdown when recurrence is off
                    items: _getRecurrenceTypeDropdownItems(),
                    dropdownColor: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<RecurrenceType>> _getRecurrenceTypeDropdownItems() {
    return [
      const DropdownMenuItem<RecurrenceType>(
        value: null,
        child: Text('None'),
      ),
      ...RecurrenceType.values.map((recurrenceType) {
        return DropdownMenuItem<RecurrenceType>(
          value: recurrenceType,
          child: Text(recurrenceType.toString().split('.').last),
        );
      }).toList(),
    ];
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
    final parsedDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dateController.text, true)
        : null;

    if (parsedDate == null && selectedTime != null) {
      // Clear time if date is null for consistency
      selectedTime = null;
      timeController.clear();
    }

    final newTask = Task(
        title: titleController.text,
        description: descController.text,
        taskCategory: selectedCategory,
        urgencyLevel: selectedPriority,
        date: parsedDate,
        time: selectedTime,
        notifyBeforeMinutes: notifyBeforeMinutes ?? 0,
        recurrenceType: selectedRecurrenceType);

    context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
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
        notifyBeforeMinutes: notifyBeforeMinutes,
        recurrenceType: selectedRecurrenceType,
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
