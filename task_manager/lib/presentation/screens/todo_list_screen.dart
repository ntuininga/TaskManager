import 'package:flutter/material.dart';
import 'package:task_manager/core/data/app_database.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/task_category.dart';
import 'package:task_manager/presentation/widgets/categories_dialog.dart';
import 'package:task_manager/presentation/widgets/new_task_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/task_card.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final AppDatabase db = AppDatabase.instance;
  List<Task?> tasks = [];
  List<TaskCategory?> taskCategories = [];
  TaskCategory? selectedCategory;

  void refreshTaskList() async {
    var refreshTasks = await db.fetchAllTasks();

    setState(() {
      tasks = refreshTasks;
    });
  }

  void refreshTaskCategoryList() async {
    var refreshTaskCategories = await db.fetchAllTaskCategories();

    if (refreshTaskCategories.isEmpty) {
      db.createTaskCategory(TaskCategory(title: "Personal"));
      db.createTaskCategory(TaskCategory(title: "Work"));
      db.createTaskCategory(TaskCategory(title: "Shopping"));
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
                    children: [
                      ElevatedButton(
                        onPressed: (){
                    
                        }, 
                        child: Text("all")),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: taskCategories.length,
                            itemBuilder: (context, index){
                              return ElevatedButton(
                                onPressed: (){
                            
                                }, 
                                child: Text(taskCategories[index]!.title));
                            }),
                        ),
                      ),
                        ElevatedButton(
                        onPressed: (){
                          showDialog(
                            context: context, 
                            builder: (BuildContext context){
                              return CategoryDialog();
                            }).then((category){
                              setState(() {
                                selectedCategory = category;
                                print(selectedCategory!.title);
                              });
                            });
                        }, 
                        child: const Text("more"))
                    ],
                  ),
                  ),
                  Expanded(
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
                  ),
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
                  onPressed: () {
      
                  }, 
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.list),
                ),                
                ElevatedButton(
                  onPressed: () => showNewTaskBottomSheet(context, refreshTaskList),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.add),
                ),
                ElevatedButton(
                  onPressed: () {
                    db.clearTasks();
                    refreshTaskList();
                    refreshTaskCategoryList();
                  }, 
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.delete),
                ),                
              ],
            ),
          )
      ],
    );
  }
}