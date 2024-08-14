import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_task_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  FilterType activeFilter = FilterType.uncomplete;
  final _categorySelectorKey = GlobalKey<CategorySelectorState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
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
                                        color: activeFilter ==
                                                FilterType.uncomplete
                                            ? Colors.blue
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
                                            ? Colors.blue
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
                                                ? Colors.blue
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
                                      filterByCategory(category.id!);
                                    },
                                  )
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
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () => showNewTaskBottomSheet(context),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding:
                    const EdgeInsets.all(20), // Adjust the size of the button
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  void filterByCategory(int id) {
    context
        .read<TasksBloc>()
        .add(FilterTasks(filter: FilterType.category, categoryId: id));
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
              onCheckboxChanged: (value) {
                setState(() {
                  tasks[index].isDone = value!;
                  // db.updateTask(tasks[index]);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
