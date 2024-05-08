import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

Future<void> showTaskDialog(BuildContext context, {String? title, TaskCategory? category, Function()? onTaskSubmit}) async {
  TextEditingController titleController = TextEditingController(text: title);
  TextEditingController dateController = TextEditingController(); // Controller for date input
  int? selectedCategoryId = category?.id;

  TaskRepository taskRepository = await GetIt.instance<TaskRepository>();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('New Task'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                autofocus: true,
                controller: titleController,
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
              // Dropdown for categories
              // if (categories != null && categories.isNotEmpty)
              //   DropdownButtonFormField<int>(
              //     value: selectedCategoryId,
              //     onChanged: (int? newValue) {
              //       selectedCategoryId = newValue;
              //     },
              //     items: categories.map((TaskCategory category) {
              //       return DropdownMenuItem<int>(
              //         value: category.id,
              //         child: Text(category.title),
              //       );
              //     }).toList(),
              //     decoration: const InputDecoration(
              //       labelText: 'Category',
              //     ),
              //   ),
              // Additional fields can be added here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder()
            ),
            onPressed: () {
              if (Form.of(context).validate()) {
                if (selectedCategoryId != null) {
                  onTaskSubmit?.call(); // Call the onTaskSubmit function if provided
                  Navigator.of(context).pop();
                } else {
                  // Handle task category not selected
                }
              }
            },
            child: const Icon(Icons.save),
          ),
        ],
      );
    },
  );
}



