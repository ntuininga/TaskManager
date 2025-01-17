import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/theme_cubit/theme_cubit.dart';

class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  final List<(String, ThemeMode)> _themes = const [
    ('Dark', ThemeMode.dark),
    ('Light', ThemeMode.light),
    ('System', ThemeMode.system)
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("App Theme"),
      content: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, selectedTheme) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _themes.length, 
              (index) {
                final String label = _themes[index].$1;
                final ThemeMode theme = _themes[index].$2;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  onTap: () => context.read<ThemeCubit>().updateTheme(theme),
                  trailing: selectedTheme == theme ? const Icon(Icons.check) : null,
                );
              },
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

Future<void> showThemeDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const ThemeDialog();
    },
  );
}
