import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

Future<void> scheduleNotificationsForRecurringTask(Task task, List<DateTime> instances) async {
  if (instances.isEmpty || task.time == null) return;

  DateTime now = DateTime.now();
  String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);

  for (DateTime instance in instances) {
    DateTime scheduledDateTime = DateTime(
      instance.year, instance.month, instance.day, task.time!.hour, task.time!.minute);

    if (task.notifyBeforeMinutes != null && task.notifyBeforeMinutes! > 0) {
      scheduledDateTime = scheduledDateTime.subtract(Duration(minutes: task.notifyBeforeMinutes!));
    }

    if (scheduledDateTime.isBefore(now)) continue;

    int notificationId = task.id! * 100000 + instance.millisecondsSinceEpoch.remainder(100000); 

    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);
    String description = "Due on ${_formatDate(instance)} at ${_formatTime(task.time!)}";

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled', 'Scheduled Notifications',
      channelDescription: 'Scheduled task reminders',
      importance: Importance.high, priority: Priority.high);

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        task.title,
        description,
        tzScheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    } catch (e) {
      debugPrint("Error scheduling recurring notification: $e");
    }
  }
}

Future<void> scheduleNotificationByTask(Task task) async {
  if (task.date == null || task.time == null) return;

  DateTime now = DateTime.now();  // Store current time once to prevent inconsistencies
  DateTime scheduledDateTime = DateTime(
    task.date!.year, task.date!.month, task.date!.day, task.time!.hour, task.time!.minute);

  if (task.notifyBeforeMinutes != null && task.notifyBeforeMinutes! > 0) {
    scheduledDateTime = scheduledDateTime.subtract(Duration(minutes: task.notifyBeforeMinutes!));
  }

  if (scheduledDateTime.isBefore(now)) return;

  await flutterLocalNotificationsPlugin.cancel(task.id!);

  String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);
  final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, location);

  String description;
  DateTime today = DateUtils.dateOnly(now);
  DateTime taskDate = DateUtils.dateOnly(task.date!);

  if (taskDate.isAtSameMomentAs(today)) {
    description = "Due today at ${_formatTime(task.time!)}";
  } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
    description = "Due tomorrow at ${_formatTime(task.time!)}";
  } else {
    description = "Due on ${_formatDate(task.date!)} at ${_formatTime(task.time!)}";
  }

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'scheduled', 'Scheduled Notifications',
    channelDescription: 'Scheduled task reminders',
    importance: Importance.high, priority: Priority.high);

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  try {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      description,
      tzScheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  } catch (e) {
    debugPrint("Error scheduling notification: $e");
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
