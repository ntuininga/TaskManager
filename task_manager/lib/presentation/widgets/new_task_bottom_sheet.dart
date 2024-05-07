import 'package:flutter/material.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/widgets/Dialogs/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';

Future<void> showNewTaskBottomSheet(BuildContext context, Function() onTaskSubmit) async {
  TextEditingController titleController = TextEditingController();
  TaskCategory? taskCategory;
  int? taskCategoryId;
  final AppDatabase db = AppDatabase.instance;
  // final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

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
                          showDialog(
                            context: context, 
                            builder: (BuildContext context){
                              return CategoryDialog();
                            }).then((category) {
                              taskCategory = category;
                              taskCategoryId = category.id;
                            });
                        }, 
                        child: const Text("Category")
                      ),
                        ElevatedButton(
                          onPressed: () {
                            showTaskDialog(context);
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
                        if (titleController.text.isNotEmpty){
                          Task newTask = Task(
                            title: titleController.text,
                            taskCategoryId: taskCategoryId
                          );
                          db.createTask(newTask);
                          onTaskSubmit();
                        }

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
