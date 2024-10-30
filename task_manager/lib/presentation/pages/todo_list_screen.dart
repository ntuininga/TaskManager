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
  FilterType activeFilter = FilterType.uncomplete;
  final _categorySelectorKey = GlobalKey<CategorySelectorState>();
  List<int> selectedTaskIds = [];
  bool isSelectedPageState = false;

  @override
  void initState() {
    super.initState();
    context
        .read<TasksBloc>()
        .add(const FilterTasks(filter: FilterType.uncomplete));
    activeFilter = FilterType.uncomplete;
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
    for (int taskId in selectedTaskIds) {
      context.read<TasksBloc>().add(DeleteTask(id: taskId));
    }
    setState(() {
      selectedTaskIds.clear();
      isSelectedPageState = false;
    });
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
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is SuccessGetTasksState) {
                          return _buildTaskList(state.filteredTasks);
                        } else if (state is NoTasksState) {
                          return const Center(child: Text("No Tasks"));
                        } else if (state is ErrorState) {
                          return Center(child: Text(state.errorMsg));
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
                    color: Colors.red,
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

  Widget _buildTaskList(List<Task> tasks) {
    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: TaskCard(
              task: tasks[index],
              isTappable: !isSelectedPageState,
              isSelected: selectedTaskIds.contains(tasks[index].id),
              onTap: () {
                if (isSelectedPageState) {
                  toggleTaskSelection(tasks[index].id!);
                }
              },
              onLongPress: () {
                setState(() {
                  if (!isSelectedPageState) {
                    selectedTaskIds.add(tasks[index].id!);
                    isSelectedPageState = true;
                  }
                });
              },
              onCheckboxChanged: (value) {
                if (value != null && index < tasks.length) {
                  setState(() {
                    tasks[index].isDone = value;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
