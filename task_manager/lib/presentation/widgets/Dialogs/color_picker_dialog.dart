import 'package:flutter/material.dart';
import 'package:task_manager/core/theme/category_colours.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color selectedColor = Colors.grey;
  final _defaultColors = defaultColors;
  List<Color?> assignedColors = [];

  @override
  void initState() {
    super.initState();

    // Access the context after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<TaskCategoriesBloc>().state;
      if (currentState is SuccessGetTaskCategoriesState) {
        assignedColors = currentState.assignedColors;
      } else {
        assignedColors =
            []; // Default empty list if the state is not SuccessGetTaskCategoriesState
      }
    });
    print(assignedColors.length);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _defaultColors.map((color) {
            final isAssigned = assignedColors.contains(color);
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
  }
}
