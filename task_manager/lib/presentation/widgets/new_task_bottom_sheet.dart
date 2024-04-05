import 'package:flutter/material.dart';
import 'package:task_manager/core/data/app_database.dart';
import 'package:task_manager/models/task.dart';

Future<void> showNewTaskBottomSheet(BuildContext context, Function() onTaskSubmit) async {
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
                  hintText: "New Task"
                  ),
              ),
              const SizedBox(height: 16.0),          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                      
                        }, 
                        child: const Text("Category")
                      ),
                        ElevatedButton(
                          onPressed: () {

                          }, 
                          child: const Text("Edit")
                        ),
                    ],
                  ),

                  SizedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder()
                      ),
                      onPressed: () {
                        // Handle saving the task here
                        Task newTask = Task(
                          title: titleController.text
                        );

                        db.createTask(newTask);
                        onTaskSubmit();
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
