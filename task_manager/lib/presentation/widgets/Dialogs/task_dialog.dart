import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

Future<void> showTaskDialog(BuildContext context, {Task? task, Function()? onTaskSubmit, bool? isUpdate}) async {
  TextEditingController titleController = TextEditingController(text: task!.title);
  TextEditingController descController = TextEditingController(text: task.description);
  TextEditingController dateController = TextEditingController(text: task.date.toString()); // Controller for date input
  int? selectedCategoryId = task.taskCategoryId;

  TaskRepository taskRepository = await GetIt.instance<TaskRepository>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('New Task'),
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
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today_rounded),
                  labelText: "Date"
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000), 
                    lastDate: DateTime(3000)
                  );
                  
                  if (pickedDate != null){
                    dateController.text = pickedDate.toIso8601String();
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (!isUpdate!){
                  Task newTask = Task(
                    title: titleController.text,
                    description: descController.text,
                    date: DateTime.parse(dateController.text)
                  );

                  taskRepository.addTask(newTask);
                } else {
                  //Update Task
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
