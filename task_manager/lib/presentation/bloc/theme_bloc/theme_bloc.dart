import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LoadingThemeState()) {
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
  }
}

Future<void> _onToggleDarkMode(ToggleDarkModeEvent event, Emitter<ThemeState> emitter) async {

}
