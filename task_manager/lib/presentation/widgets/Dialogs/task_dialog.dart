import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

Future<void> showTaskDialog(BuildContext context, {Task? task, Function()? onTaskSubmit, bool isUpdate = false}) async {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  final TextEditingController titleController = TextEditingController(text: task?.title ?? '');
  final TextEditingController descController = TextEditingController(text: task?.description ?? '');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController dateController = TextEditingController(text: task?.date != null ? dateFormat.format(task!.date!) : ''); // Controller for date input
  int? selectedCategoryId = task?.taskCategoryId;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isUpdate ? 'Update Task' : 'New Task'),
        content: Form(
          key: _formKey,
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
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              //Category Input
              CategorySelector(
                initialId: task?.taskCategoryId,
                onChanged: (value){
                task?.taskCategoryId = value!.id;
              }),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today_rounded),
                  labelText: "Date"
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode()); // Close the keyboard
                  DateTime? pickedDate = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000), 
                    lastDate: DateTime(3000)
                  );
                  
                  if (pickedDate != null){
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
            ],
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
              if (_formKey.currentState!.validate()) {
                if (!isUpdate) {
                  Task newTask = Task(
                    title: titleController.text,
                    description: descController.text,
                    date: DateTime.parse(dateController.text),
                    taskCategoryId: selectedCategoryId,
                  );
                  await taskRepository.addTask(newTask);
                } else {
                  // Update Task
                  task?.title = titleController.text;
                  task?.description = descController.text;
                  task?.date = DateTime.parse(dateController.text);
                  if (task != null) {
                    await taskRepository.updateTask(task);
                  }
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
}
