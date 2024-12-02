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
  TaskCategory? defaultCategory;
  TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  final GlobalKey<CategorySelectorState> categorySelectorKey = GlobalKey<CategorySelectorState>();

  @override
  void initState() {
    super.initState();
    _initializeDefaultCategory();
  }

  void _initializeDefaultCategory() async {
    TaskCategory category = await taskRepository.getCategoryById(0);
    setState(() {
      defaultCategory = category;
      task.taskCategory = category;
    });

    // Now that the default category is set, apply the active filter
    _setDefaultValuesBasedOnFilter();
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
            task.taskCategory = filteredCategory ?? defaultCategory;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the UI builds only when task.category is set
    if (task.taskCategory == null) {
      return const CircularProgressIndicator(); // You can show a loading indicator until the category is set
    }

    return BlocListener<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is SuccessGetTasksState) {
          _setDefaultValuesBasedOnFilter();
        }
      },
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
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
                            key: categorySelectorKey,
                            hasCircle: true,
                            initialCategory: filteredCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                task.taskCategory = category;
                                filteredCategory = category;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (task.taskCategory != null) {
                                  showTaskPageOverlay(
                                    context,
                                    task: Task(
                                      title: titleController.text,
                                      urgencyLevel: task.urgencyLevel,
                                      taskCategory: task.taskCategory,
                                    ),
                                  );
                                }
                              },
                              child: const Text("More"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          onPressed: () {
                            if (titleController.text.isNotEmpty &&
                                task.taskCategory != null) {
                              // Create a new task
                              Task newTask = Task(
                                title: titleController.text,
                                urgencyLevel: task.urgencyLevel,
                                taskCategory: task.taskCategory,
                              );

                              // Save the task
                              context
                                  .read<TasksBloc>()
                                  .add(AddTask(taskToAdd: newTask));

                              // Reset the task and category selector
                              setState(() {
                                titleController.clear();
                                if (filteredCategory == null) {
                                  task = Task(taskCategory: defaultCategory);
                                  categorySelectorKey.currentState
                                      ?.resetCategory();
                                } else {
                                  task.taskCategory = filteredCategory;
                                }
                                filteredCategory = null;
                              });
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
