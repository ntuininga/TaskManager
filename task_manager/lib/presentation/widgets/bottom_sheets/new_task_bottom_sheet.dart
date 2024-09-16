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
  const NewTaskBottomSheet({super.key});

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  Task task = Task();
  TaskCategory? filteredCategory;

  TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });

    _initializeDefaultCategory();
    _setDefaultValuesBasedOnFilter();
  }

  // Initialize default category if no filter is applied
  void _initializeDefaultCategory() async {
    TaskCategory category = await taskRepository.getCategoryById(0);
    setState(() {
      task.taskCategory = category;
    });
  }

  // Set default values based on the active filter
  void _setDefaultValuesBasedOnFilter() {
    final TasksBloc tasksBloc = BlocProvider.of<TasksBloc>(context);
    final currentState = tasksBloc.state;

    if (currentState is SuccessGetTasksState) {
      final activeFilter = currentState.activeFilter;

      if (activeFilter != null) {
        // Handle urgency filter
        if (activeFilter.filterType == FilterType.urgency) {
          setState(() {
            task.urgencyLevel = TaskPriority.high;
          });
        }
        // Handle category filter
        else if (activeFilter.filterType == FilterType.category) {
          setState(() {
            filteredCategory = activeFilter.filteredCategory;
            task.taskCategory = filteredCategory ?? task.taskCategory;
          });
        }
        // Add more cases here if you have more filters (e.g., date, priority)
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
    return BlocListener<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is SuccessGetTasksState) {
          // Ensure the filter is applied correctly if the state updates
          _setDefaultValuesBasedOnFilter();
        }
      },
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          final categoryTitle = task.taskCategory?.title ?? 'No Category';
          print("Current Task Category: $categoryTitle");

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                    minLines: 1,
                    maxLines: 10,
                    decoration: const InputDecoration(hintText: "New Task"),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CategorySelector(
                            initialCategory: filteredCategory ?? task.taskCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                task.taskCategory = category;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (task.taskCategory != null) {
                                print("Task Category before edit: ${task.taskCategory!.title}");
                                showTaskPageOverlay(
                                  context,
                                  task: Task(
                                    title: titleController.text,
                                    urgencyLevel: task.urgencyLevel,
                                    taskCategory: filteredCategory ?? task.taskCategory,
                                  ),
                                );
                              }
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
                            if (titleController.text.isNotEmpty && task.taskCategory != null) {
                              Task newTask = Task(
                                title: titleController.text,
                                urgencyLevel: task.urgencyLevel,
                                taskCategory: filteredCategory ?? task.taskCategory,
                              );
                              context.read<TasksBloc>().add(AddTask(taskToAdd: newTask));
                              Navigator.of(context).pop();
                            } else {
                              print("Task title or category is not set.");
                            }
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
      ),
    );
  }

  void showTaskPageOverlay(BuildContext context, {Task? task}) {
    Navigator.of(context).pop();
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
