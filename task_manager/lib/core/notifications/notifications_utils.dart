import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';
import 'package:task_manager/core/utils/timezone.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotification);

  tz.initializeTimeZones();
}

Future onDidReceiveNotification(NotificationResponse response) async {
  //handle notifcation tap here
}

Future onDidReceiveBackgroundNotification(NotificationResponse response) async {
  //handle notifcation tap here
}

Future<void> showNotification() async {}

Future<void> scheduleNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('scheduled', 'Scheduled Notifications',
          channelDescription: 'Schedule notifications at a specific time');

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Scheduled Notification',
      'This notification was scheduled',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}

Future<void> scheduleNotificationByTask(Task task) async {
  if (task.date == null || task.time == null) return;

  // Combine date and time into one DateTime object, subtract notifyBeforeMinutes.
  DateTime scheduledDateTime = DateTime(
      task.date!.year, task.date!.month, task.date!.day, task.time!.hour, task.time!.minute);
  
  if (task.notifyBeforeMinutes != null && task.notifyBeforeMinutes! > 0) {
    scheduledDateTime = scheduledDateTime.subtract(Duration(minutes: task.notifyBeforeMinutes!));
  }

  // Ensure the scheduled time is in the future
  if (scheduledDateTime.isBefore(DateTime.now())) return;

  // Cancel any existing notification for this task
  await flutterLocalNotificationsPlugin.cancel(task.id!);

  // Get timezone details
  final timeZone = TimeZone();
  String timeZoneName = await timeZone.getTimeZoneName();
  final location = await timeZone.getLocation(timeZoneName);
  final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);

  // Prepare notification description based on due date
  final now = DateTime.now();
  String description;
  if (task.date!.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
    description = "Due today at ${_formatTime(task.time!)}";
  } else if (task.date!.isAtSameMomentAs(DateTime(now.year, now.month, now.day).add(Duration(days: 1)))) {
    description = "Due tomorrow at ${_formatTime(task.time!)}";
  } else {
    description = "Due on ${_formatDate(task.date!)} at ${_formatTime(task.time!)}";
  }

  // Notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('scheduled', 'Scheduled Notifications',
          channelDescription: 'Scheduled task reminders',
          importance: Importance.high, priority: Priority.high);

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      description,
      tzScheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}


// Helper function to format time as "3:00 AM/PM"
String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod; // Handle 12 AM/PM
  final period = time.period == DayPeriod.am ? "AM" : "PM";
  return "${hour}:${time.minute.toString().padLeft(2, '0')} $period";
}

// Helper function to format date as "Day/Month/Year"
String _formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

