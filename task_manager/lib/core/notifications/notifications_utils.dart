import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/utils/datetime_utils.dart';
import 'package:task_manager/data/entities/recurring_instance_entity.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
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

Future<void> scheduleNotificationsForRecurringTask(
    Task task, List<DateTime> instances) async {
  if (instances.isEmpty || task.time == null) return;
  int count = 0;
  for (DateTime instance in instances) {
    Task newTask = Task(
      id: task.id,
      title: task.title,
      date: instance, // Set the date to the current instance's date
      time:
          task.time, // Retain the same time// Retain the same notification time
    );

    await scheduleNotificationByTask(newTask, suffix: count);
    count++;
  }
}

int datetimeHash(DateTime dateTime) {
  // Encodes date & time into a number between 0–999
  final int dayPart = dateTime.day;
  final int hourPart = dateTime.hour;
  final int minutePart = dateTime.minute;

  return ((dayPart * 24 + hourPart) * 60 + minutePart) % 1000;
}

int generateNotificationId(int taskId, DateTime occurrenceDate) {
  // Set base date as Jan 1, 2000
  final DateTime baseDate = DateTime(2000, 1, 1);
  final int daysSinceEpoch = occurrenceDate.difference(baseDate).inDays;

  // Allow up to 9999 unique days per task (about 27 years of recurrence)
  return taskId * 10000 + daysSinceEpoch;
}


Future<void> scheduleNotificationForRecurringInstance(
  RecurringInstance recurringInstance,
  String taskTitle, {
  int suffix = 1,
}) async {
  if (recurringInstance.occurrenceDate == null ||
      recurringInstance.occurrenceTime == null) return;

  final DateTime now = DateTime.now();
  final DateTime scheduledDateTime = DateTime(
    recurringInstance.occurrenceDate!.year,
    recurringInstance.occurrenceDate!.month,
    recurringInstance.occurrenceDate!.day,
    recurringInstance.occurrenceTime!.hour,
    recurringInstance.occurrenceTime!.minute,
  );

  // Skip past instances
  if (scheduledDateTime.isBefore(now) && !isSameDay(scheduledDateTime, now)) {
    return;
  }

  if (recurringInstance.taskId == null) return;

  final int suffix = datetimeHash(scheduledDateTime);


  final int notificationId = generateNotificationId(recurringInstance.taskId!, scheduledDateTime);

  await flutterLocalNotificationsPlugin.cancel(notificationId);

  final String timeZoneName = await getTimeZoneName();
  final location = await getTimeZoneLocation(timeZoneName);
  final tz.TZDateTime tzScheduledDate =
      tz.TZDateTime.from(scheduledDateTime, location);

  final String description =
      "Due on ${_formatDate(recurringInstance.occurrenceDate!)} at ${_formatTime(recurringInstance.occurrenceTime!)}";

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
      notificationId,
      taskTitle,
      description,
      tzScheduledDate,
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("Scheduled notification for $taskTitle");
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
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
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
  final pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  // Use integer division to match taskId part of the ID
  final matchingIds = pendingNotifications
      .map((n) => n.id)
      .where((id) => id ~/ 10000 == taskId)
      .toList();

  if (matchingIds.isNotEmpty) {
    for (final id in matchingIds) {
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

Future<void> cancelNotification(int taskId, DateTime date) async {
  final int daysSinceEpoch = date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  final int id = taskId * 10000 + daysSinceEpoch;

  await flutterLocalNotificationsPlugin.cancel(id);
}



String _formatTime(TimeOfDay time) {
  return "${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? "AM" : "PM"}";
}

String _formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
