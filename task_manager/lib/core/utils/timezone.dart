import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeZone {
  static final TimeZone _instance = TimeZone._internal();

  factory TimeZone() {
    return _instance;
  }

  TimeZone._internal() {
    tz.initializeTimeZones(); // Initialize time zones
  }

  String getTimeZoneName() {
    // Returns the local time zone name from the system
    return tz.local.name; // tz.local is the local time zone
  }

  tz.Location getLocation([String? timeZoneName]) {
    timeZoneName ??= getTimeZoneName();
    return tz.getLocation(timeZoneName);
  }
}
