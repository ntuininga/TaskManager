part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateDateFormat extends SettingsEvent {
  final String dateFormat;
  UpdateDateFormat(this.dateFormat);
}

class UpdateCheckboxFormat extends SettingsEvent {
  final bool isCheckboxCircle;
  UpdateCheckboxFormat(this.isCheckboxCircle);
}