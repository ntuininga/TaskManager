
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class CategorySelector extends StatefulWidget {
  final int? initialId;
  final ValueChanged<TaskCategory?>? onChanged;
  const CategorySelector({this.initialId,this.onChanged, super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  List<TaskCategory> taskCategories = [];
  TaskCategory? selectedCategory;


  @override
  void initState() {
    refreshCategories();

    // setState(() {
    //   if (widget.initialId != null){
    //     selectedCategory = taskCategories.firstWhere((value) => value.id == widget.initialId);
    //   }
    // });
    super.initState();
  }

  void refreshCategories() async {
    var refreshCategories = await taskRepository.getAllCategories();
    setState(() {
      taskCategories = refreshCategories;
    });
  }

  List<DropdownMenuItem<TaskCategory>> get dropdownItems {
    List<DropdownMenuItem<TaskCategory>> items = 
      taskCategories.map((TaskCategory value) {
        return DropdownMenuItem<TaskCategory>(
          value: value,
          child: Text(value.title)
          );
      }).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(50.0)
      ),
      child: DropdownButton<TaskCategory>(
        hint: const Text("Category"),
        value: selectedCategory,
        items: dropdownItems, 
        onChanged: (value){
          setState(() {
            selectedCategory = value;
          });
          widget.onChanged!(value);
        },
        ),
    );
  }
}
