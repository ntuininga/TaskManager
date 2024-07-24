import 'package:flutter/material.dart';

class ThemeDialog extends StatelessWidget {

  ThemeDialog({super.key});

  bool? darkMode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("App Theme"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Dark Mode"),
          Switch(
            onChanged: (value) {
              
            },
            value: darkMode ?? false,
          ),
        ],
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
        return ThemeDialog();
      });
}
