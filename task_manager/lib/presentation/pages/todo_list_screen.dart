import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    context
        .read<TasksBloc>()
        .add(const FilterTasks(filter: FilterType.uncomplete));
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

  void toggleTaskSelection(int taskId) {
    setState(() {
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
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                        width: 1.5,
                                        color: activeFilter ==
                                                FilterType.uncomplete
                                            ? activeColour
                                            : Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<TasksBloc>().add(
                                          const FilterTasks(
                                              filter: FilterType.uncomplete));
                                      setState(() {
                                        activeFilter = FilterType.uncomplete;
                                      });
                                      _categorySelectorKey.currentState
                                          ?.resetCategory();
                                    },
                                    child: const Text("All"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                        color: activeFilter == FilterType.date
                                            ? activeColour
                                            : Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<TasksBloc>().add(
                                          const FilterTasks(
                                              filter: FilterType.date));
                                      setState(() {
                                        activeFilter = FilterType.date;
                                      });
                                      _categorySelectorKey.currentState
                                          ?.resetCategory();
                                    },
                                    child: const Text("Date"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                        color:
                                            activeFilter == FilterType.urgency
                                                ? activeColour
                                                : Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.read<TasksBloc>().add(
                                          const FilterTasks(
                                              filter: FilterType.urgency));
                                      setState(() {
                                        activeFilter = FilterType.urgency;
                                      });
                                      _categorySelectorKey.currentState
                                          ?.resetCategory();
                                    },
                                    child: const Text("Urgency"),
                                  ),
                                  const SizedBox(width: 8),
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
                          Container(
                            alignment: Alignment.center,
                            width: 20,
                            child: PopupMenuButton(
                              padding: const EdgeInsets.all(0),
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  child: const Text("Overdue"),
                                  onTap: () {
                                    context.read<TasksBloc>().add(
                                        const FilterTasks(
                                            filter: FilterType.overdue));
                                    setState(() {
                                      activeFilter = FilterType.overdue;
                                    });
                                    _categorySelectorKey.currentState
                                        ?.resetCategory();
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("Completed"),
                                  onTap: () {
                                    context.read<TasksBloc>().add(
                                        const FilterTasks(
                                            filter: FilterType.completed));
                                    setState(() {
                                      activeFilter = FilterType.completed;
                                    });
                                    _categorySelectorKey.currentState
                                        ?.resetCategory();
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("No Date"),
                                  onTap: () {
                                    context.read<TasksBloc>().add(
                                        const FilterTasks(
                                            filter: FilterType.nodate));
                                    setState(() {
                                      activeFilter = FilterType.nodate;
                                    });
                                    _categorySelectorKey.currentState
                                        ?.resetCategory();
                                  },
                                ),
                              ],
                            ),
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
                        } else if (state is SuccessGetTasksState) {
                          final newTasks = state.filteredTasks;

                          // Identify tasks to add or update
                          for (var newTask in newTasks) {
                            final index = taskList
                                .indexWhere((task) => task.id == newTask.id);

                            if (index == -1) {
                              // New task - insert at the top
                              taskList.insert(0, newTask);
                              _listKey.currentState?.insertItem(0);
                            } else {
                              // Existing task - update in place
                              taskList[index] = newTask;
                            }
                          }

                          // Remove tasks no longer in the filtered list
                          for (var oldTask in List.of(taskList)) {
                            if (!newTasks
                                .any((newTask) => newTask.id == oldTask.id)) {
                              final index = taskList.indexOf(oldTask);
                              _listKey.currentState?.removeItem(
                                index,
                                (context, animation) =>
                                    _buildRemovedTask(oldTask, animation),
                              );
                              taskList.removeAt(index);
                            }
                          }
                          return _buildAnimatedTaskList();
                        } else if (state is NoTasksState) {
                          return const Center(child: Text("No Tasks"));
                        } else if (state is ErrorState) {
                          return const Center(child: Text("An Error Occurred"));
                        } else {
                          return const Center(child: Text("Unknown Error"));
                        }
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
            child: Container(
              height: 60,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedTaskIds.clear();
                        isSelectedPageState = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    '${selectedTaskIds.length} selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: deleteSelectedTasks,
                    icon: const Icon(Icons.delete),
                    color: isDeletePressed
                        ? Colors.red
                        : Theme.of(context).dividerColor,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
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
          key: _listKey,
          initialItemCount: taskList.length,
          itemBuilder: (context, index, animation) {
            return animatedTaskCard(context, index, animation);
          }),
    );
  }

  Widget animatedTaskCard(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0, // Ensures the animation flows from the top.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: TaskCard(
            task: taskList[index],
            onCheckboxChanged: (value) {
              if (value == true) {
                final removedTask =
                    taskList[index]; // Capture the task before removing
                taskList.removeAt(index); // Update the list immediately

                // Trigger the removal animation
                _listKey.currentState!.removeItem(
                  index,
                  (_, animation) => _buildRemovedTask(removedTask, animation),
                  duration: const Duration(
                      milliseconds: 250), // Adjust duration as needed
                );
              }
            }),
      ),
    );
  }
}
