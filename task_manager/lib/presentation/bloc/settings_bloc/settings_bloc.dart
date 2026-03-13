import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(SettingsState(dateFormat: 'MM/dd/yyyy', isCircleCheckbox: true)) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDateFormat>(_onUpdateDateFormat);
    on<UpdateCheckboxFormat>(_onUpdateCheckboxFormat);

    // Load immediately on construction so UI never shows stale defaults
    add(LoadSettings());
  }

  // Consistent key constants — the source of your bug
  static const _keyDateFormat = 'dateFormat';
  static const _keyIsCircleCheckbox = 'isCircleCheckbox'; // was 'isCheckboxCircle' on save

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(
      dateFormat: prefs.getString(_keyDateFormat) ?? 'MM/dd/yyyy',
      isCircleCheckbox: prefs.getBool(_keyIsCircleCheckbox) ?? true,
    ));
  }

  Future<void> _onUpdateDateFormat(
      UpdateDateFormat event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateFormat, event.dateFormat);
    emit(state.copyWith(dateFormat: event.dateFormat));
  }

  Future<void> _onUpdateCheckboxFormat(
      UpdateCheckboxFormat event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsCircleCheckbox, event.isCheckboxCircle); // fixed key
    emit(state.copyWith(isCircleCheckbox: event.isCheckboxCircle));
  }
}
