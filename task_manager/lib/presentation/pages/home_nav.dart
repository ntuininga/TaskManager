import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/user.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/domain/repositories/user_repository.dart';
import 'package:task_manager/presentation/pages/home_screen.dart';
import 'package:task_manager/presentation/pages/lists_screen.dart';
import 'package:task_manager/presentation/pages/settings_screen.dart';

class HomeNav extends StatefulWidget {
  final int initialIndex;
  const HomeNav({super.key, this.initialIndex = 0});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();
  final UserRepository userRepository = GetIt.instance<UserRepository>();

  User? user;
  List<Task> taskList = [];
  List<Task> uncompletedTasks = [];
  List<Task> completedTasks = [];

  late int _selectedIndex;

  static const List<Widget> _pages = [
    HomeScreen(),
    ListsScreen(),
    SettingsScreen()
  ];

  void refreshData() async {
    var newUserData = await userRepository.getUserData();
    var completedTaskListData = await taskRepository.getCompletedTasks();
    var uncompletedTaskListData = await taskRepository.getUnfinishedTasks();

    setState(() {
      user = newUserData;
      uncompletedTasks = uncompletedTaskListData;
      completedTasks = completedTaskListData;
      taskList = uncompletedTasks + completedTasks;
    });
  }

  @override
  void initState() {
    refreshData();

    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemSelected(int index) {
  setState(() {
    _selectedIndex = index;
  });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemSelected,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Tasks"
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings"
            ),
        ]  
        ),
      ),
    );
  }
}