import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState(dateFormat: 'MM/dd/yyyy')) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateDateFormat>(_onUpdateDateFormat);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedFormat = prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
    emit(state.copyWith(dateFormat: savedFormat));
  }

  Future<void> _onUpdateDateFormat(
      UpdateDateFormat event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateFormat', event.dateFormat);
    emit(state.copyWith(dateFormat: event.dateFormat));
  }
}

