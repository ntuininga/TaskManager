enum WeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

extension WeekDayExtension on WeekDay {
  String get label {
    switch (this) {
      case WeekDay.sunday:
        return 'Sunday';
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
      default:
        return '';
    }
  }

  // Convert the enum to a short string representation
  String toShortString() {
    return this.toString().split('.').last;
  }

  // Parse a string back to the enum
  static WeekDay fromString(String value) {
    return WeekDay.values.firstWhere((e) => e.toString().split('.').last == value, orElse: () => WeekDay.sunday);
  }
}
