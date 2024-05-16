import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';

Future<void> showNewTaskBottomSheet(BuildContext context, Function() onTaskSubmit, List<TaskCategory> categories) async {
  TextEditingController titleController = TextEditingController();
  TaskCategory? selectedCategory = categories[0];

  TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
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
                        DropdownButton<TaskCategory>(
                          hint: const Text("Category"),
                          value: selectedCategory,
                          items: categories.map((category){
                            return DropdownMenuItem<TaskCategory>(
                              value: category,
                              child: Text(category.title)
                              );
                          }).toList(), 
                          onChanged: (TaskCategory? value){
                            setState (){
                              selectedCategory = value;
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showTaskDialog(context, title: titleController.text);
        
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
                              taskCategoryId: selectedCategory!.id
                            );
        
                            taskRepository.addTask(newTask);
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
        }
      );
    },
  );
}
