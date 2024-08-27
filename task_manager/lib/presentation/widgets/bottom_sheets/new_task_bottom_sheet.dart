import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/data/entities/task_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/task_page.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';

class NewTaskBottomSheet extends StatefulWidget {
  const NewTaskBottomSheet({
    super.key,
  });

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  TaskCategory? newTaskCategory;
  Task task = Task();

  TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  @override
  void initState() {
    super.initState();

    _initializeDefaultCategory();
    _setDefaultValuesBasedOnFilter();
  }

  void _initializeDefaultCategory() async {
    // Assuming TaskRepository has a method to fetch a category by ID
    newTaskCategory = await taskRepository.getCategoryById(0);
    setState(() {}); // Ensure UI reflects the selected default category
  }

void _setDefaultValuesBasedOnFilter() {
  final TasksBloc tasksBloc = BlocProvider.of<TasksBloc>(context);
  final currentState = tasksBloc.state;

  if (currentState is SuccessGetTasksState) {
    final activeFilter = currentState.activeFilter;
    
    if (activeFilter != null) {
      if (activeFilter.activeFilter == FilterType.urgency) {
        task.urgencyLevel = TaskPriority.high;
      } else if (activeFilter.activeFilter == FilterType.category) {
        task.taskCategory = activeFilter.filteredCategory ?? task.taskCategory;
        newTaskCategory = task.taskCategory; // Set newTaskCategory to avoid null
      }
      setState(() {});
    }
  }
}


  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TasksBloc tasksBloc = BlocProvider.of<TasksBloc>(context);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              decoration: const InputDecoration(hintText: "New Task"),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CategorySelector(
                      initialCategory: task.taskCategory,
                      onCategorySelected: (category) {
                      setState(() {
                        task.taskCategory = category;
                      });
                    }),
                    ElevatedButton(
                      onPressed: () {
                        showTaskPageOverlay(context,
                            task: Task(
                                title: titleController.text,
                                urgencyLevel: task.urgencyLevel,
                                taskCategory: newTaskCategory,
                                taskCategoryId: newTaskCategory?.id));
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
                      if (titleController.text.isNotEmpty) {
                        Task newTask = Task(
                            title: titleController.text,
                            urgencyLevel: task.urgencyLevel,
                            taskCategoryId: newTaskCategory?.id);
                        context
                            .read<TasksBloc>()
                            .add(AddTask(taskToAdd: newTask));
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

  void showTaskPageOverlay(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) => TaskPage(task: task),
      ),
    );
  }
}

Future<void> showNewTaskBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return const NewTaskBottomSheet();
    },
  );
}
