part of 'settings_bloc.dart';

abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateDateFormat extends SettingsEvent {
  final String dateFormat;
  UpdateDateFormat(this.dateFormat);
}
