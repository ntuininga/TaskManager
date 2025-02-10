import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/weekday.dart'; // Assuming Frequency and WeekDay are imported from here

class RecurrenceRuleset {
  Frequency frequency;
  DateTime? until;
  int? count;
  int? interval;
  List<WeekDay>? weekDays;

  RecurrenceRuleset({
    this.frequency = Frequency.daily,
    this.until,
    this.count,
    this.interval,
    this.weekDays,
  });

  // Convert to string representation
  String toShortString() {
    List<String> parts = [];

    parts.add('frequency=${frequency.toShortString()}');
    if (until != null) {
      parts.add('until=${until!.toIso8601String()}');
    }
    if (count != null) {
      parts.add('count=$count');
    }
    if (interval != null) {
      parts.add('interval=$interval');
    }
    if (weekDays != null && weekDays!.isNotEmpty) {
      parts.add('weekDays=${weekDays!.map((e) => e.toShortString()).join(',')}');
    }

    return parts.join(';');
  }

  // Deserialize from string representation
static RecurrenceRuleset fromString(String? str) {
  if (str == null || str.isEmpty) {
    // If the string is null or empty, return a default RecurrenceRuleset or handle as needed.
    return RecurrenceRuleset(
      frequency: Frequency.daily, // Default frequency
      until: null,
      count: null,
      interval: null,
      weekDays: [],
    );
  }

  Map<String, String> values = {};

  for (var part in str.split(';')) {
    var keyValue = part.split('=');
    if (keyValue.length == 2) {
      values[keyValue[0]] = keyValue[1];
    }
  }

  // Default values
  Frequency frequency = Frequency.daily;
  DateTime? until;
  int? count;
  int? interval;
  List<WeekDay>? weekDays;

  // Safely parse the values with null checks
  if (values.containsKey('frequency') && values['frequency'] != null) {
    frequency = FrequencyExtension.fromString(values['frequency']!);
  }
  if (values.containsKey('until') && values['until'] != null) {
    until = DateTime.tryParse(values['until']!);
  }
  if (values.containsKey('count') && values['count'] != null) {
    count = int.tryParse(values['count']!);
  }
  if (values.containsKey('interval') && values['interval'] != null) {
    interval = int.tryParse(values['interval']!);
  }
  if (values.containsKey('weekDays') && values['weekDays'] != null) {
    weekDays = values['weekDays']!
        .split(',')
        .map((e) => WeekDayExtension.fromString(e))
        .toList();
  }

  return RecurrenceRuleset(
    frequency: frequency,
    until: until,
    count: count,
    interval: interval,
    weekDays: weekDays,
  );
}

}
