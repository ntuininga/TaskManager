// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:test/test.dart'; // Import the test package

// // Mock class for FlutterLocalNotificationsPlugin
// class MockFlutterLocalNotificationsPlugin extends Mock
//     implements FlutterLocalNotificationsPlugin {}

// void main() {
//   late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;

//   // Register fallback value for NotificationDetails and RepeatInterval
//   setUpAll(() {
//     registerFallbackValue(NotificationDetails());
//     registerFallbackValue(RepeatInterval.daily);
//   });

//   setUp(() {
//     // Initialize the mock object before each test
//     mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

//     // Mock the response for periodicallyShow method
//     when(() => mockNotificationsPlugin.periodicallyShow(
//           any(),
//           any(),
//           any(),
//           any(),
//           any(),
//         )).thenAnswer((_) async {
//       // Simulate a successful notification scheduling.
//       print('Mocked notification scheduled');
//     });
//   });

//   test('Test scheduling 7 daily notifications at a specific time', () async {
//     // Simulate scheduling 7 notifications with a daily frequency at a specific time
//     for (int i = 0; i < 7; i++) {
//       await mockNotificationsPlugin.periodicallyShow(
//         i, // Notification ID
//         'Test Recurring Notification', // Title
//         'This is test notification #$i', // Body text
//         RepeatInterval.daily, // Daily repeat interval
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'daily_notifications',
//             'Daily Notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//           ),
//         ),
//       );
//     }

//     // Verify that periodicallyShow was called 7 times
//     verify(() => mockNotificationsPlugin.periodicallyShow(
//           any(),
//           any(),
//           any(),
//           any(),
//           any(),
//         )).called(7); // Ensure it's called exactly 7 times

//     // Optionally, verify correct NotificationDetails for each call
//     for (int i = 0; i < 7; i++) {
//       verify(() => mockNotificationsPlugin.periodicallyShow(
//             i, // Notification ID
//             'Test Recurring Notification', // Title
//             'This is test notification #$i', // Body text
//             RepeatInterval.daily, // Repeat interval
//             captureAny(), // Capture NotificationDetails for comparison
//           )).called(1); // Ensure each notification call is made once
//     }

//     // Capture all the NotificationDetails passed to the mocked method
//     final capturedNotificationDetails =
//         verify(() => mockNotificationsPlugin.periodicallyShow(
//               any(),
//               any(),
//               any(),
//               any(),
//               captureAny(),
//             )).captured;

//     // Assert the correct NotificationDetails values for each captured argument
//     for (var details in capturedNotificationDetails) {
//       expect(details, isA<NotificationDetails>());
//       expect(details.android!.channelId, equals('daily_notifications'));
//       expect(details.android!.importance, equals(Importance.high));
//       expect(details.android!.priority, equals(Priority.high));
//     }
//   });

//   test('Test notification scheduling', () async {
//     // Simulating notification scheduling using the mock
//     await mockNotificationsPlugin.periodicallyShow(
//       0,
//       'Test Recurring Notification',
//       'This is a test notification',
//       RepeatInterval.everyMinute,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_notifications',
//           'Daily Notifications',
//         ),
//       ),
//     );

//     // Verify that periodicallyShow was called with any parameters exactly once
//     verify(() => mockNotificationsPlugin.periodicallyShow(
//           any(),
//           any(),
//           any(),
//           any(),
//           any(),
//         )).called(1);
//   });
// }
