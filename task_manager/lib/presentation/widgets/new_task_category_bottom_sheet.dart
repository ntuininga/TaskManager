import 'package:flutter/material.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/task_category.dart';

Future<void> showNewTaskCategoryBottomSheet(BuildContext context, Function() onTaskCategorySubmit) async {
  TextEditingController titleController = TextEditingController();
  final AppDatabase db = AppDatabase.instance;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                autofocus: true,
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "New Task Category"
                  ),
              ),
              const SizedBox(height: 16.0),          
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder()
                  ),
                  onPressed: () {
                    // Handle saving the task here
                    TaskCategory newCategory = TaskCategory(
                      title: titleController.text
                      );
                    
                    db.createTaskCategory(newCategory);
                    onTaskCategorySubmit();
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
