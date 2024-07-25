import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
      colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark, 
          seedColor: Colors.green));

  static ThemeData get light => ThemeData(
      colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light, 
          seedColor: Colors.green));

  static ThemeData get lightBlue => ThemeData(
      colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light, 
          seedColor: Colors.blue));
}
