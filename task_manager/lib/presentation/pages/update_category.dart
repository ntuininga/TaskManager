import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/color_schemes.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';

class UpdateCategoryPage extends StatefulWidget {
  final TaskCategory category;

  const UpdateCategoryPage({required this.category, super.key});

  @override
  _UpdateCategoryPageState createState() => _UpdateCategoryPageState();
}

class _UpdateCategoryPageState extends State<UpdateCategoryPage> {
  late TextEditingController titleController;
  late Color selectedColor;
  late Set<int> assignedColorValues;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.category.title);
    selectedColor = widget.category.colour!;
    assignedColorValues = _getAssignedColors();
  }

  Set<int> _getAssignedColors() {
    final currentState = context.read<TaskCategoriesBloc>().state;
    if (currentState is SuccessGetTaskCategoriesState) {
      return currentState.assignedColors
          .where((color) => color != null && color != widget.category.colour)
          .map((color) => color!.value)
          .toSet();
    }
    return {};
  }

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
            children: defaultColors.map((color) {
              final isAssigned = assignedColorValues.contains(color.value);
              final isSelected = color.value == selectedColor.value;

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
                          color: isSelected ? Theme.of(context).focusColor : Colors.black12,
                          width: isSelected ? 3 : 1, // Thicker border for the selected color
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    if (isAssigned)
                      const Icon(
                        Icons.close,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Update Category"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<TaskCategoriesBloc>().add(DeleteTaskCategory(id: widget.category.id!, deleteAssociatedTasks: false));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Category Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                TaskCategory updatedCategory = TaskCategory(
                  id: widget.category.id,
                  title: titleController.text,
                  colour: selectedColor,
                );
                context.read<TaskCategoriesBloc>().add(UpdateTaskCategory(taskCategoryToUpdate: updatedCategory));
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
