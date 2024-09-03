import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/core/notifications/notification_repository.dart';

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotification,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotification
  );
}

Future onDidReceiveNotification(NotificationResponse response) async {
  //handle notifcation tap here
}

Future onDidReceiveBackgroundNotification(NotificationResponse response) async {
  //handle notifcation tap here
}

Future<void> showNotification() async {

}

Future<void> scheduleNotification() async {

}