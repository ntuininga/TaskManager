import 'package:flutter/material.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';
import 'package:task_manager/presentation/screens/lists_screen.dart';
import 'package:task_manager/presentation/screens/settings_screen.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _selectedIndex = 1;

  static const List<Widget> _pages = [
    HomeScreen(),
    ListsScreen(),
    SettingsScreen()
  ];

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