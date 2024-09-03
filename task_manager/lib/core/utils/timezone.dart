// import 'package:timezone/data/latest.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// class TimeZone {
//   static final TimeZone _instance = TimeZone._internal();

//   factory TimeZone() {
//     return _instance;
//   }

//   TimeZone._internal() {
//     initializeTimeZones();
//   }

//   Future<String> getTimeZoneName() async {
//     return FlutterNativeTimezone.getLocalTimezone();
//   }

//   Future<tz.Location> getLocation([String? timeZoneName]) async {
//     if (timeZoneName == null || timeZoneName.isEmpty) {
//       timeZoneName = await getTimeZoneName();
//     }
//     return tz.getLocation(timeZoneName);
//   }
// }
