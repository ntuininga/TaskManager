import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';
import 'package:task_manager/presentation/pages/home/grouped_home_screen.dart';
import 'package:task_manager/presentation/pages/lists_screen.dart';
import 'package:task_manager/presentation/pages/settings_screen.dart';
import 'package:task_manager/presentation/widgets/bottom_sheets/new_task_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class HomeNav extends StatefulWidget {
  final int initialIndex;
  const HomeNav({super.key, this.initialIndex = 0});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  late int _selectedIndex;

  bool notificationsEnabled = false;

  static const List<Widget> _pages = [
    GroupedHomeScreen(),
    ListsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // requestPermission();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _selectedIndex = widget.initialIndex;
    context.read<TasksBloc>().add(const OnGettingTasksEvent(withLoading: true));
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> requestPermission() async {
    const permission = Permission.reminders;

    bool status = await checkPermissionStatus();

    if (status) {
      await permission.request();
    }
  }

  Future<bool> checkPermissionStatus() async {
    const permissionAlarms = Permission.reminders;
    const permissionNotifications = Permission.notification;
    if (await permissionNotifications.status.isGranted &&
        await permissionAlarms.isGranted) return true;
    return false;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        notificationsEnabled = granted;
      });
    }
  }

  void _onAddButtonPressed() {
    showNewTaskBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        floatingActionButton: _selectedIndex != 2 // Hide FAB on Settings screen
            ? FloatingActionButton(
                onPressed: _onAddButtonPressed,
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          elevation: 15,
          currentIndex: _selectedIndex,
          onTap: _onItemSelected,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
            BottomNavigationBarItem(
                icon: Icon(Icons.all_inbox), label: "Tasks"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
