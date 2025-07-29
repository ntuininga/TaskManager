part of 'settings_bloc.dart';

class SettingsState {
  final String dateFormat;
  final bool isCircleCheckbox;

  SettingsState({required this.dateFormat, required this.isCircleCheckbox});

  SettingsState copyWith({String? dateFormat, bool? isCircleCheckbox}) {
    return SettingsState(
      dateFormat: dateFormat ?? this.dateFormat,
      isCircleCheckbox: isCircleCheckbox ?? this.isCircleCheckbox,
    );
  }
}
