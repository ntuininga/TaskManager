import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/widgets/are_you_sure_dialog.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_task_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/animated_task_list.dart'; // <-- use new widget

class GroupedListScreen extends StatefulWidget {
  final TaskCategory? category;
  final String? title;
  final FilterType? specialFilter;

  const GroupedListScreen({
    super.key,
    this.category,
    this.title,
    this.specialFilter,
  });

  @override
  State<GroupedListScreen> createState() => _GroupedListScreenState();
}

class _GroupedListScreenState extends State<GroupedListScreen> {
  final Set<int> selectedTaskIds = {};
  bool isSelectionMode = false;

  void _onAddButtonPressed(BuildContext context, TaskCategory? category) {
    showNewTaskBottomSheet(context, initialCategory: category);
  }

  void toggleTaskSelection(int? taskId) {
    setState(() {
      if (selectedTaskIds.contains(taskId)) {
        selectedTaskIds.remove(taskId);
        if (selectedTaskIds.isEmpty) isSelectionMode = false;
      } else {
        if (taskId != null) {
          selectedTaskIds.add(taskId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? widget.category?.title ?? ''),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // edit logic
              } else if (value == 'delete') {
                final bloc = context.read<TaskCategoriesBloc>();
                showConfirmationDialog(
                  context: context,
                  title: 'Do you really want to delete this category?',
                  okText: 'Delete',
                  cancelText: 'Cancel',
                ).then((confirmed) {
                  if (confirmed == true) {
                    bloc.add(DeleteTaskCategory(id: widget.category!.id ?? 0));
                  }
                });
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is ErrorState) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            if (state is NoTasksState) {
              return Center(
                child: Text(
                  'No tasks found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            if (state is! SuccessGetTasksState) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Task> tasks;
            if (widget.specialFilter != null) {
              switch (widget.specialFilter) {
                case FilterType.dueToday:
                  tasks = state.today;
                  break;
                case FilterType.urgency:
                  tasks = state.urgent;
                  break;
                case FilterType.overdue:
                  tasks = state.overdue;
                  break;
                default:
                  tasks = [];
              }
            } else {
              tasks = state.tasksByCategory[widget.category]
                      ?.where((task) => !task.isDone)
                      .toList() ??
                  [];
            }

            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  'No tasks',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: AnimatedTaskList(
                tasks: tasks,
                dateFormat: "yyyy-MM-dd", // or pull from settings if needed
                isCircleCheckbox: true, // or pull from settings if needed
                onCheckboxChanged: (task) {
                  // handle checkbox toggle
                },
                onTaskTap: (task) {
                  if (isSelectionMode) toggleTaskSelection(task.id);
                },
                onTaskLongPress: (task) {
                  toggleTaskSelection(task.id);
                  setState(() => isSelectionMode = true);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddButtonPressed(context, widget.category),
        child: const Icon(Icons.add),
      ),
    );
  }
}
