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
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedFormat = prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
    final savedCheckbox = prefs.getBool('isCircleCheckbox') ?? true;
    emit(state.copyWith(
        dateFormat: savedFormat, isCircleCheckbox: savedCheckbox));
  }

  Future<void> _onUpdateCheckboxFormat(
      UpdateCheckboxFormat event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckboxCircle', event.isCheckboxCircle);
    emit(state.copyWith(isCircleCheckbox: event.isCheckboxCircle));
  }

  Future<void> _onUpdateDateFormat(
      UpdateDateFormat event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateFormat', event.dateFormat);
    emit(state.copyWith(dateFormat: event.dateFormat));
  }
}
