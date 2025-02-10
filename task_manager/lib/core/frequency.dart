enum Frequency {
  daily,
  weekly,
  monthly,
  yearly,
  hourly,
  minutely,
  secondly,
}

extension FrequencyExtension on Frequency {
  String get label {
    switch (this) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.monthly:
        return 'Monthly';
      case Frequency.yearly:
        return 'Yearly';
      case Frequency.hourly:
        return 'Hourly';
      case Frequency.minutely:
        return 'Minutely';
      case Frequency.secondly:
        return 'Secondly';
      default:
        return '';
    }
  }

  // This method will help convert the enum to a string
  String toShortString() {
    return this.toString().split('.').last;
  }

  // This method helps to parse a string back to an enum
  static Frequency fromString(String value) {
    return Frequency.values.firstWhere((e) => e.toString().split('.').last == value, orElse: () => Frequency.daily);
  }
}
