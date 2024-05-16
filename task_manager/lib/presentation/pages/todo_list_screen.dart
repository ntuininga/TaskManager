import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/data/datasources/local/app_database.dart';
import 'package:task_manager/data/entities/task_category_entity.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/tasks_bloc.dart';
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
  // List<TaskCategoryEntity?> taskCategories = [];
  TaskCategory? selectedCategory;

  void refreshTaskList() async {
    var refreshTasks = await taskRepository.getAllTasks();

    setState(() {
      tasks = refreshTasks;
    });
  }

  void refreshTaskCategoryList() async {
    var refreshTaskCategories = await taskRepository.getAllCategories();

    if (refreshTaskCategories.isEmpty) {
      taskRepository.addTaskCategory(TaskCategory(title: "Personal"));
      taskRepository.addTaskCategory(TaskCategory(title: "Work"));
      taskRepository.addTaskCategory(TaskCategory(title: "Shopping"));
      refreshTaskCategoryList();
    }

    setState(() {
      taskCategories = refreshTaskCategories;
    });
  }

  @override
  void initState(){
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
                    children: [
                      ElevatedButton(
                        onPressed: (){
                    
                        }, 
                        child: Text("all")
                      ),
                      ElevatedButton(
                        onPressed: (){

                        }, 
                        child: const Text("Date")
                      ),
                      ElevatedButton(
                        onPressed: (){

                        }, 
                        child: const Text("Urgency")
                      ),
                      ElevatedButton(
                        onPressed: (){

                        }, 
                        child: const Text("Category")
                      ),
                    ],
                  ),
                  ),
                  _buildTaskList()
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

  _buildTaskList() {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (_,state) {
        if (state is LoadingGetTasksState) {
          return const Expanded(child: Center(child: CircularProgressIndicator()));
        }
        if (state is SuccessGetTasksState) {
          return Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index){
                return TaskCard(
                  task: tasks[index]!, 
                  onCheckboxChanged: (value) {
                    setState(() {
                      tasks[index]!.isDone = value!;
                      db.updateTask(tasks[index]!);
                    });
                  });
              },
            ),
          );
        }
        else {
          return const SizedBox();
        }
      }
    );
  }
}