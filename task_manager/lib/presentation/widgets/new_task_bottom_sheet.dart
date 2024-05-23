import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/Dialogs/task_dialog.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class NewTaskBottomSheet extends StatefulWidget {
  final Function() onTaskSubmit;
  final List<TaskCategory> categories;

  const NewTaskBottomSheet({
    required this.onTaskSubmit,
    required this.categories,
    super.key,
  });

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  TaskCategory? selectedCategory;

  TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.isNotEmpty ? widget.categories[0] : null;
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              focusNode: titleFocusNode,
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
                    CategorySelector(onChanged: (value){
                      selectedCategory = value;
                    }),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showTaskDialog(context, task: Task(title: titleController.text), onTaskSubmit: widget.onTaskSubmit);
                      },
                      child: const Text("Edit"),
                    ),
                  ],
                ),
                SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      if (titleController.text.isNotEmpty && selectedCategory != null) {
                        Task newTask = Task(
                          title: titleController.text,
                          taskCategoryId: selectedCategory!.id,
                        );
                        taskRepository.addTask(newTask);
                        widget.onTaskSubmit();
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
}

Future<void> showNewTaskBottomSheet(BuildContext context, Function() onTaskSubmit, List<TaskCategory> categories) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return NewTaskBottomSheet(
        onTaskSubmit: onTaskSubmit,
        categories: categories,
      );
    },
  );
}
