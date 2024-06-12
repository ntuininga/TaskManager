import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';
import 'package:task_manager/presentation/widgets/new_task_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  final AppDatabase db = AppDatabase.instance;

  List<Task?> tasks = [];
  List<TaskCategory> taskCategories = [];
  TaskCategory? selectedCategory;
  String activeFilter = "All"; // Add this variable

  void refreshTaskList() async {
    var refreshTasks = await taskRepository.getUnfinishedTasks();
    setState(() {
      tasks = refreshTasks;
      selectedCategory = null;
      activeFilter = "All"; // Update active filter
    }); 
  }

  void refreshTaskCategoryList() async {
    var refreshTaskCategories = await taskRepository.getAllCategories();

    if (refreshTaskCategories.isEmpty) {
      taskRepository.addTaskCategory(TaskCategory(title: "Personal", colour: Colors.amber));
      taskRepository.addTaskCategory(TaskCategory(title: "Work", colour: Colors.red));
      taskRepository.addTaskCategory(TaskCategory(title: "Shopping"));
      refreshTaskCategoryList();
    }

    setState(() {
      taskCategories = refreshTaskCategories;
    });
  }

  void sortTasksByDate() {
    setState(() {
      tasks.sort((a, b) {
        if (a!.date == null && b!.date == null) return 0;
        if (a.date == null) return 1;
        if (b!.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });
      selectedCategory = null;
      activeFilter = "Date"; // Update active filter
    });
  }

  void sortTasksByCategory(int categoryId) async {
    var allTasks = await taskRepository.getAllTasks();
    setState(() {
      tasks = allTasks.where((task) => task.taskCategoryId == categoryId).toList();
      activeFilter = "Category"; // Update active filter
    });
  }

  void sortTasksByUrgency() async {
    setState(() {
      activeFilter = "Urgency";
    });
  }

  void sortTasksByCompleted() async {
    var completedTasks = await taskRepository.getCompletedTasks();
    setState(() {
      tasks = completedTasks;
    });
  }

  @override
  void initState() {
    refreshTaskList();
    refreshTaskCategoryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: activeFilter == "All" ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        onPressed: () {
                          refreshTaskList();
                        },
                        child: const Text("All"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: activeFilter == "Date" ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        onPressed: () {
                          sortTasksByDate();
                        },
                        child: const Text("Date"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            color: activeFilter == "Urgency" ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        onPressed: () {
                          sortTasksByUrgency();
                        },
                        child: const Text("Urgency"),
                      ),
                      CategorySelector(
                        onChanged: (value) {
                          if (value != null) {
                            sortTasksByCategory(value.id!);
                            setState(() {
                              activeFilter = "Category"; // Update active filter
                            });
                          }
                        },
                      ),
                      Container(
                        width: 20,
                        child: PopupMenuButton(itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: Text("Completed"),
                            onTap: () {
                              sortTasksByCompleted();
                            },)
                        ]),
                      )
                    ],
                  ),
                ),
                BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, state) {
                    if (state is LoadingGetTasksState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SuccessGetTasksState) {
                      return _buildTaskList(state.tasks);
                    } else if (state is NoTasksState) {
                      return const Center(child: Text("No Tasks"));
                    } else {
                      return const Center(child: Text("Error has occured"));
                    }
                  }),
                // _buildTaskList()
              ],
            ),
          ),
        ),
        Container(
          height: 65,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => showNewTaskBottomSheet(context, refreshTaskList, taskCategories),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskCard(
            task: tasks[index],
            onCheckboxChanged: (value) {
              setState(() {
                tasks[index].isDone = value!;
                db.updateTask(tasks[index]);
              });
            },
          );
        },
      ),
    );
  }
}
