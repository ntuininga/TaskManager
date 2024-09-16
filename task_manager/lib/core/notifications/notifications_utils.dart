import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';
import 'package:task_manager/core/utils/timezone.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

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

Future<void> scheduleNotificationByDateAndTime(
    Task task, DateTime date, TimeOfDay time) async {

  DateTime dateTime =
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  final timeZone = TimeZone();
  String timeZoneName = await timeZone.getTimeZoneName();

  // // Find the 'current location'
  final location = await timeZone.getLocation(timeZoneName);

  final scheduledDate = tz.TZDateTime.from(dateTime, location);


  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('scheduled', 'Scheduled Notifications',
          channelDescription: 'Schedule notifications at a specific time');

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      'Due: ${task.date} Time: ${task.time}',
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}
