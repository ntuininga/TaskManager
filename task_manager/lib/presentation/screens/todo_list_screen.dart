import 'package:flutter/material.dart';
import 'package:task_manager/core/data/app_database.dart';
import 'package:task_manager/models/task.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final AppDatabase db = AppDatabase.instance;
  List<Task?> tasks = [];

  void refreshTaskList() async {
    var refreshTasks = await db.fetchAllTasks();
    print(refreshTasks.length);
    setState(() {
      tasks = refreshTasks;
    });
  }

  @override
  void initState(){
    refreshTaskList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 500,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index){
                return Card(
                  child: Column(
                    children: [
                      Text(tasks[index]!.title)
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Task newTask = Task(
                  title: "Test Todo",
                  description: "Is this working",
                  isDone: false
                );

                db.createTask(newTask);
                refreshTaskList();
              }, 
              child: Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
              ),
            ),
          )
        ],
      )
    );
  }
}