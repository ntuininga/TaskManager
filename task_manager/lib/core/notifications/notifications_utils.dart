import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

Future<String> getTimeZoneName() async {
  try {
    return await FlutterTimezone.getLocalTimezone();
  } catch (e) {
    return 'UTC'; // Fallback in case of an error
  }
}

Future<tz.Location> getTimeZoneLocation(String timeZoneName) async {
  try {
    return tz.getLocation(timeZoneName);
  } catch (e) {
    return tz.getLocation('UTC'); // Fallback to UTC
  }
}

Future<void> scheduleNotificationsForRecurringTask(
    Task task, List<DateTime> instances) async {
  if (instances.isEmpty || task.time == null) return;

  // Iterate over each instance and schedule a notification
  for (DateTime instance in instances) {
    // Create a new task based on the instance date
    Task newTask = Task(
      id: task.id,
      title: task.title,
      date: instance, // Set the date to the current instance's date
      time: task.time, // Retain the same time
      notifyBeforeMinutes:
          task.notifyBeforeMinutes, // Retain the same notification time
    );

    // Use scheduleNotificationByTask to schedule the notification
    await scheduleNotificationByTask(newTask);
  }
}

Future<void> scheduleNotificationByTask(Task task) async {
  if (task.date == null || task.time == null) return;

  DateTime now =
      DateTime.now(); // Store current time once to prevent inconsistencies
  DateTime scheduledDateTime = DateTime(task.date!.year, task.date!.month,
      task.date!.day, task.time!.hour, task.time!.minute);

  if (scheduledDateTime.isBefore(now)) return;

  await flutterLocalNotificationsPlugin.cancel(task.id!);

  String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);
  final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);

  String description;
  DateTime today = DateUtils.dateOnly(now);
  DateTime taskDate = DateUtils.dateOnly(task.date!);

  description =
      "Due on ${_formatDate(task.date!)} at ${_formatTime(task.time!)}";


  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled', 'Scheduled Notifications',
      channelDescription: 'Scheduled task reminders',
      importance: Importance.high,
      priority: Priority.high);

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  int notificationId = int.parse(
          sha256
              .convert(utf8
                  .encode('${task.id!}:${scheduledDateTime.toIso8601String()}'))
              .toString()
              .substring(0, 8),
          radix: 16) %
      2147483647;

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(notificationId,
        task.title, description, tzScheduledDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  } catch (e) {
    debugPrint("Error scheduling notification: $e");
  }
}

Future<void> checkAllScheduledNotifications() async {
  try {
    // Retrieve all scheduled notifications
    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    if (pendingNotifications.isEmpty) {
      print("No scheduled notifications.");
    } else {
      // Iterate through all pending notifications
      for (var notification in pendingNotifications) {
        print(
            'Notification ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }
    }
  } catch (e) {
    print("Error fetching scheduled notifications: $e");
  }
}

Future<void> cancelAllNotificationsForTask(int taskId) async {
  try {
    // Cancel the scheduled notification by task ID
    await flutterLocalNotificationsPlugin.cancel(taskId);

    debugPrint("Successfully canceled notification for task ID: $taskId");
  } catch (e) {
    debugPrint("Error while canceling notification for task ID: $taskId: $e");
  }
}

String _formatTime(TimeOfDay time) {
  return "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}";
}

String _formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
