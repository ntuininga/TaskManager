import 'package:flutter/material.dart';

class MainNavBar extends StatefulWidget {

  const MainNavBar({
    super.key
    });

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemSelected,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home"
          ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings"
          ),
      ]  
    );
  }
}