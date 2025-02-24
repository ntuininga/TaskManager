import 'package:task_manager/core/frequency.dart';
import 'package:task_manager/core/weekday.dart'; // Assuming Frequency and WeekDay are imported from here

class RecurrenceRuleset {
  Frequency? frequency;
  DateTime? until;
  int? count;
  int? interval;
  List<WeekDay>? weekDays;

  RecurrenceRuleset({
    this.frequency,
    this.until,
    this.count,
    this.interval,
    this.weekDays,
  });

  // Convert to string representation
  String toShortString() {
    List<String> parts = [];

    parts.add('frequency=${frequency?.toShortString()}');
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

static RecurrenceRuleset fromString(String? str) {
  if (str == null || str.isEmpty) {
    return RecurrenceRuleset(
      frequency: null,
      until: null,
      count: null,
      interval: null,
      weekDays: [],
    );
  }

  final values = {
    for (var part in str.split(';'))
      if (part.contains('=')) part.split('=')[0]: part.split('=')[1]
  };

  final frequency = values['frequency'] != null
      ? FrequencyExtension.fromString(values['frequency']!)
      : null;

  final until = values['until'] != null ? DateTime.tryParse(values['until']!) : null;
  final count = values['count'] != null ? int.tryParse(values['count']!) : null;
  final interval = values['interval'] != null ? int.tryParse(values['interval']!) : null;
  final weekDays = values['weekDays'] != null && values['weekDays']!.isNotEmpty
      ? values['weekDays']!.split(',').map(WeekDayExtension.fromString).toList()
      : <WeekDay>[];

  return RecurrenceRuleset(
    frequency: frequency,
    until: until,
    count: count,
    interval: interval,
    weekDays: weekDays,
  );
}


}
