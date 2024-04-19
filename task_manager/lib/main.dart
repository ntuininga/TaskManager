import 'package:flutter/material.dart';
import 'package:task_manager/presentation/screens/home_nav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeNav(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeNav()
      },
    );
  }
}
