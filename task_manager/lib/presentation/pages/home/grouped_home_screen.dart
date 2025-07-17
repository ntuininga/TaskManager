import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/grouped_list_screen/grouped_list_screen.dart';
import 'package:task_manager/presentation/pages/home/widgets/grouped_card_widget.dart';

class GroupedHomeScreen extends StatefulWidget {
  const GroupedHomeScreen({super.key});

  @override
  State<GroupedHomeScreen> createState() => _GroupedHomeScreenState();
}

class _GroupedHomeScreenState extends State<GroupedHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              BlocBuilder<TasksBloc, TasksState>(builder: (context, state) {
                if (state is SuccessGetTasksState) {
                  return Expanded(
                    child: Column(
                      children: [
                        // Top row with Today, Urgent, Overdue
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GroupedCardWidget(
                                  title: "Today",
                                  categoryTaskCount: state.today.length,
                                  color: state.today.isNotEmpty ? Colors.red : Colors.grey,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupedListScreen(
                                          tasks: state.today,
                                          title: 'Due Today',
                                        ),
                                      ),
                                    );
                                  },                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GroupedCardWidget(
                                  title: "Urgent",
                                  categoryTaskCount: state.urgent.length,
                                  color: state.urgent.isNotEmpty ? Colors.red : Colors.grey,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupedListScreen(
                                          tasks: state.urgent,
                                          title: 'Urgent',
                                        ),
                                      ),
                                    );
                                  },   
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GroupedCardWidget(
                                  title: "Overdue",
                                  categoryTaskCount: state.overdue.length,
                                  color: state.overdue.isNotEmpty ? Colors.red : Colors.grey,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupedListScreen(
                                          tasks: state.today,
                                          title: 'Overdue',
                                        ),
                                      ),
                                    );
                                  },   
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(thickness: 2),
                        const SizedBox(height: 24),
                        // Grid of category cards
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 2,
                            children: state.allCategories.map((category) {
                              final tasks =
                                  state.tasksByCategory[category] ?? [];
                              return GroupedCardWidget(
                                category: category,
                                categoryTaskCount: tasks.length,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupedListScreen(
                                          tasks: tasks,
                                          title: category.title ?? 'Tasks',
                                        ),
                                      ),
                                    );
                                  },   
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is LoadingGetTasksState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ErrorState) {
                  return Center(child: Text(state.errorMsg));
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
