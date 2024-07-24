part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class OnGettingThemeEvent extends ThemeEvent {
  final bool withLoading;

  const OnGettingThemeEvent({required this.withLoading});
}

class ToggleDarkModeEvent extends ThemeEvent {}
