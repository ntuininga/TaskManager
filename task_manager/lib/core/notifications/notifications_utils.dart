import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/recurring_instance_entity.dart';
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
  int count = 0;
  for (DateTime instance in instances) {
    Task newTask = Task(
      id: task.id,
      title: task.title,
      date: instance, // Set the date to the current instance's date
      time: task.time, // Retain the same time// Retain the same notification time
    );

    await scheduleNotificationByTask(newTask, suffix: count);
    count++;
  }
}

Future<void> scheduleNotificationForRecurringInstance(
  RecurringInstanceEntity recurringInstance,
  String taskTitle, { // Accepting taskTitle as a parameter
  int suffix = 1,
}) async {
  if (recurringInstance.occurrenceDate == null || recurringInstance.occurrenceTime == null) return;

  DateTime now = DateTime.now();
  DateTime scheduledDateTime = DateTime(
    recurringInstance.occurrenceDate!.year,
    recurringInstance.occurrenceDate!.month,
    recurringInstance.occurrenceDate!.day,
    recurringInstance.occurrenceTime!.hour,
    recurringInstance.occurrenceTime!.minute,
  );

  // Check if the scheduled time is before the current time
  if (scheduledDateTime.isBefore(now) && 
      !isSameDay(scheduledDateTime, now)) {
    return;
  }


  // Create a unique notification ID using instanceId and suffix
  int notificationId = int.parse('${recurringInstance.taskId}000$suffix');

  // Cancel any existing notification with the same ID before rescheduling
  await flutterLocalNotificationsPlugin.cancel(notificationId);

  // Get the timezone info and convert scheduledDateTime to TZDateTime
  String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);
  final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);

  String description =
      "Due on ${_formatDate(recurringInstance.occurrenceDate!)} at ${_formatTime(recurringInstance.occurrenceTime!)}";

  // Define Android Notification details
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'scheduled_recurring',
    'Recurring Notifications',
    channelDescription: 'Recurring task reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // Use unique ID (taskId + suffix)
      taskTitle, // Use taskTitle as the notification title
      description,
      tzScheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } catch (e) {
    debugPrint("Error scheduling recurring instance notification: $e");
  }
}


Future<void> scheduleNotificationByTask(Task task, {int suffix = 1}) async {
  if (task.date == null || task.time == null) return;

  DateTime now = DateTime.now();
  DateTime scheduledDateTime = DateTime(
    task.date!.year,
    task.date!.month,
    task.date!.day,
    task.time!.hour,
    task.time!.minute,
  );

  if (scheduledDateTime.isBefore(now)) return;

  // Create a unique ID by combining task ID and suffix
  int notificationId = int.parse('${task.id}000$suffix');

  // Cancel any existing notification with the same ID before rescheduling
  await flutterLocalNotificationsPlugin.cancel(notificationId);

  String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);
  final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);

  String description =
      "Due on ${_formatDate(task.date!)} at ${_formatTime(task.time!)}";

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'scheduled',
    'Scheduled Notifications',
    channelDescription: 'Scheduled task reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // Use unique ID (task.id + suffix)
      task.title,
      description,
      tzScheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
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
  List<PendingNotificationRequest> pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  // Filter notifications with matching task ID prefix
  List<int> matchingIds = pendingNotifications
      .where((n) {
        String idStr = n.id.toString();
        return idStr.contains('000') && idStr.split('000').first == '$taskId';
      })
      .map((n) => n.id)
      .toList();

  if (matchingIds.isNotEmpty) {
    for (int id in matchingIds) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
    debugPrint('Cancelled ${matchingIds.length} notifications for task $taskId');
  } else {
    debugPrint('No notifications found for task $taskId');
  }
}




Future<void> cancelAllNotifications() async {
  try {
    await flutterLocalNotificationsPlugin.cancelAll();
  } catch (e) {
    debugPrint("Error while cancelling all notifications");
  }
}

String _formatTime(TimeOfDay time) {
  return "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}";
}

String _formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
