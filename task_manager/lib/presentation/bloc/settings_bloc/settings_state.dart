part of 'settings_bloc.dart';

class SettingsState {
  final String dateFormat;

  SettingsState({required this.dateFormat});

  SettingsState copyWith({String? dateFormat}) {
    return SettingsState(
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

