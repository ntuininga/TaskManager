import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/animated_task_list.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/filter_button.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/filter_sort_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> taskList = [];
  FilterType activeFilter = FilterType.uncomplete;
  final _categorySelectorKey = GlobalKey<CategorySelectorState>();
  List<int> selectedTaskIds = [];

  bool isSelectedPageState = false;
  bool isDeletePressed = false;
  bool? isBulkComplete = false;
  TaskCategory? bulkSelectedCategory;

  @override
  void initState() {
    super.initState();
    activeFilter = FilterType.uncomplete;
  }

  Widget _buildRemovedTask(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: TaskCard(
        task: task,
        onCheckboxChanged: null, // Disable interaction for removed item
      ),
    );
  }

  void toggleTaskSelection(int? taskId) {
    setState(() {
      if (taskId == null) return;

      if (selectedTaskIds.contains(taskId)) {
        selectedTaskIds.remove(taskId);
      } else {
        selectedTaskIds.add(taskId);
      }

      if (selectedTaskIds.isEmpty) {
        isSelectedPageState = false;
      }
    });
  }

  void handleBulkActions() {
    if (isBulkComplete != null) {
      context.read<TasksBloc>().add(BulkUpdateTasks(
          taskIds: List.from(selectedTaskIds), markComplete: isBulkComplete!));
    }

    // Handle Bulk Category Change
    if (bulkSelectedCategory != null) {
      TaskCategory? selectedCategory = bulkSelectedCategory;
      context.read<TasksBloc>().add(BulkUpdateTasks(
          taskIds: List.from(selectedTaskIds), newCategory: selectedCategory));
    }

    // Clear selection mode after applying actions
    setState(() {
      selectedTaskIds.clear();
      isBulkComplete = false;
      isSelectedPageState = false;
    });
  }

  void deleteSelectedTasks() {
    if (isDeletePressed) {
      for (int taskId in selectedTaskIds) {
        context.read<TasksBloc>().add(DeleteTask(id: taskId));
      }
      setState(() {
        selectedTaskIds.clear();
        isSelectedPageState = false;
      });
    } else {
      setState(() {
        isDeletePressed = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && isDeletePressed) {
          setState(() {
            isDeletePressed = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColour = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // Filter Buttons and Category Selector
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centers everything horizontally
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Ensures content is centered
                                children: [
                                  FilterButton(
                                    label: "All",
                                    filter: FilterType.uncomplete,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.uncomplete),
                                  ),
                                  const SizedBox(width: 4),
                                  FilterButton(
                                    label: "Late",
                                    filter: FilterType.overdue,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.overdue),
                                  ),
                                  const SizedBox(width: 4),
                                  FilterButton(
                                    label: "Urgent",
                                    filter: FilterType.urgency,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.urgency),
                                  ),
                                  const SizedBox(width: 4),
                                  CategorySelector(
                                    key: _categorySelectorKey,
                                    onCategorySelected: (category) {
                                      filterByCategory(category);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // This Spacer pushes the IconButton to the far right
                          IconButton(
                            icon: const Icon(Icons.filter_alt_rounded),
                            color: activeColour,
                            padding: EdgeInsets.zero, // Removes all padding
                            tooltip: 'Filter & Sort',
                            onPressed: () => _openFilterSortPanel(context),
                          ),
                        ],
                      ),
                    ),

                    // Task List
                    BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        if (state is LoadingGetTasksState) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

if (state is SuccessGetTasksState) {
  final newTasks = state.displayTasks;

  String taskKey(Task t) => t.recurringInstanceId?.toString() ?? 'id:${t.id}';

  // Remove tasks from taskList that no longer match the filter
  for (var oldTask in List.of(taskList)) {
    if (!newTasks.any((t) => taskKey(t) == taskKey(oldTask))) {
      final index = taskList.indexOf(oldTask);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedTask(oldTask, animation),
      );
      taskList.removeAt(index);
    }
  }

  // Reorder check with proper identifiers
  bool isSameSetButReordered =
      taskList.length == newTasks.length &&
      taskList.map(taskKey).toSet().containsAll(newTasks.map(taskKey)) &&
      !listEquals(taskList.map(taskKey).toList(), newTasks.map(taskKey).toList());

  if (isSameSetButReordered) {
    for (int i = taskList.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => _buildRemovedTask(taskList[i], animation),
        duration: Duration.zero,
      );
    }
    taskList.clear();
    for (int i = 0; i < newTasks.length; i++) {
      taskList.add(newTasks[i]);
      _listKey.currentState?.insertItem(i, duration: Duration.zero);
    }
    return _buildAnimatedTaskList();
  }

  // Add/update tasks
  for (var newTask in newTasks) {
    final index = taskList.indexWhere((task) => taskKey(task) == taskKey(newTask));

    if (index == -1) {
      final insertIndex = newTasks.indexOf(newTask);
      taskList.insert(insertIndex, newTask);
      _listKey.currentState?.insertItem(insertIndex);
    } else {
      taskList[index] = newTask;
    }
  }

  return _buildAnimatedTaskList();
}



                        if (state is NoTasksState) {
                          return const Center(child: Text("No Tasks"));
                        }

                        if (state is ErrorState) {
                          return const Center(child: Text("An Error Occurred"));
                        }

                        return const Center(child: Text("Unknown Error"));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Overlay Toolbar for Task Selection Mode
        if (isSelectedPageState)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SelectionToolbar(
              selectedCount: selectedTaskIds.length,
              isDeletePressed: isDeletePressed,
              isBulkComplete: isBulkComplete,
              bulkSelectedCategory: bulkSelectedCategory,
              onDeletePressed: deleteSelectedTasks,
              onClosePressed: () {
                setState(() {
                  selectedTaskIds.clear();
                  isSelectedPageState = false;
                });
              },
              onCategorySelected: (category) {
                setState(() {
                  bulkSelectedCategory = category;
                });
              },
              onBulkCompleteChanged: (value) {
                setState(() {
                  isBulkComplete = value;
                });
              },
              onConfirmPressed: handleBulkActions,
            ),
          )
      ],
    );
  }

  void _openFilterSortPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterSortPanel(
        onFilterChanged: (filter, sortType, category) {
          if (filter != null) {
            context
                .read<TasksBloc>()
                .add(FilterTasks(filter: filter, category: category));
          } else if (sortType != null) {
            context.read<TasksBloc>().add(SortTasks(sortType: sortType));
          }
        },
      ),
    );
  }

  void _applyFilter(FilterType filter) {
    context.read<TasksBloc>().add(FilterTasks(filter: filter));
    setState(() => activeFilter = filter);
    _categorySelectorKey.currentState?.resetCategory();
  }

  void filterByCategory(TaskCategory category) {
    context
        .read<TasksBloc>()
        .add(FilterTasks(filter: FilterType.category, category: category));
    setState(() {
      activeFilter = FilterType.category;
    });
  }

  Widget _buildAnimatedTaskList() {
    return Expanded(
      child: AnimatedList(
          physics: const BouncingScrollPhysics(),
          key: _listKey,
          initialItemCount: taskList.length,
          itemBuilder: (context, index, animation) {
            return animatedTaskCard(context, index, animation);
          }),
    );
  }

  void rebuildAnimatedList(List<Task> newList) {
    final oldLength = taskList.length;
    for (int i = oldLength - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => animatedTaskCard(context, i, animation),
        duration: const Duration(milliseconds: 150),
      );
    }

    setState(() {
      taskList = List.from(newList);
    });

    for (int i = 0; i < taskList.length; i++) {
      _listKey.currentState
          ?.insertItem(i, duration: const Duration(milliseconds: 150));
    }
  }

  Widget animatedTaskCard(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0, 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: TaskCard(
          task: taskList[index],
          isSelected: selectedTaskIds.contains(taskList[index].id),
          isTappable: !isSelectedPageState,
          onCheckboxChanged: (value) {
              // final removedTask =
              //     taskList[index]; // Capture the task before removing
              // taskList.removeAt(index); // Update the list immediately

              // // Trigger the removal animation
              // _listKey.currentState!.removeItem(
              //   index,
              //   (_, animation) => _buildRemovedTask(removedTask, animation),
              //   duration: const Duration(
              //       milliseconds: 250), // Adjust duration as needed
              // );
          },
          onTap: () {
            if (isSelectedPageState) {
              toggleTaskSelection(taskList[index].id);
              // if (selectedTaskIds.isEmpty) {
              //   isSelectedPageState = false;
              // }
            }
          },
          onLongPress: () {
            toggleTaskSelection(taskList[index].id);
            setState(() {
              isSelectedPageState = true;
            });
          },
        ),
      ),
    );
  }
}
