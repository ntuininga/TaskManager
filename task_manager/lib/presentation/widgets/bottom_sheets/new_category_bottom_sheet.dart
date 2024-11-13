import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

class NewCategoryBottomSheet extends StatefulWidget {
  final List<Color?> assignedColors;

  const NewCategoryBottomSheet({super.key, required this.assignedColors});

  @override
  NewCategoryBottomSheetState createState() => NewCategoryBottomSheetState();
}

class NewCategoryBottomSheetState extends State<NewCategoryBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  Color selectedColor = Colors.grey;

  final List<Color> _defaultColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  void pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _defaultColors.map((color) {
                final isAssigned = widget.assignedColors.contains(color);
                print(color.toString());
                return GestureDetector(
                  onTap: () {
                    if (!isAssigned) {
                      setState(() {
                        selectedColor = color;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isAssigned ? color.withOpacity(0.4) : color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black12,
                            width: isAssigned ? 2 : 0,
                          ),
                        ),
                      ),
                      if (isAssigned)
                        const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => pickColor(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: titleController,
                    decoration: const InputDecoration(hintText: "New Category"),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    TaskCategory newCategory = TaskCategory(
                      title: titleController.text,
                      colour: selectedColor,
                    );
                    context
                        .read<TaskCategoriesBloc>()
                        .add(AddTaskCategory(taskCategoryToAdd: newCategory));
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showNewCategoryBottomSheet(BuildContext context) async {
  List<Color?> assignedColors = [];
  final currentState = context.read<TaskCategoriesBloc>().state;

  if (currentState is SuccessGetTaskCategoriesState) {
    assignedColors = currentState.assignedColors;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      print(assignedColors.length);
      return NewCategoryBottomSheet(assignedColors: assignedColors);
    },
  );
}
