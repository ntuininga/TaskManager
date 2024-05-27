import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:collection/collection.dart';

class CategorySelector extends StatefulWidget {
  final int? initialId;
  final ValueChanged<TaskCategory?>? onChanged;
  const CategorySelector({this.initialId, this.onChanged, super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  List<TaskCategory> taskCategories = [];
  TaskCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    refreshCategories();
  }

  void refreshSelected() {
    if (widget.initialId != null) {
      print(widget.initialId);
      var matchingCategory = taskCategories.firstWhereOrNull(
        (value) => value.id == widget.initialId
      );
      setState(() {
        selectedCategory = matchingCategory;
      });
    }
  }

  void refreshCategories() async {
    var refreshCategories = await taskRepository.getAllCategories();
    setState(() {
      taskCategories = refreshCategories;
      refreshSelected(); // Ensure refreshSelected is called after categories are fetched
    });
  }

  List<DropdownMenuItem<TaskCategory>> get dropdownItems {
    return taskCategories.map((TaskCategory value) {
      return DropdownMenuItem<TaskCategory>(
        value: value,
        child: Text(value.title),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(50.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButton<TaskCategory>(
          hint: const Text("Category"),
          value: selectedCategory,
          items: dropdownItems,
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
        ),
      ),
    );
  }
}
