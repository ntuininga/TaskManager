import 'package:flutter/material.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/pages/home_nav.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injections.dart';

void main() async {
  await initializeDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TasksBloc>(
          create: (context) => sl()..add(const OnGettingTasksEvent(withLoading: true)),
        ),
        BlocProvider<TaskCategoriesBloc>(
          create: (context) => sl<TaskCategoriesBloc>()..add(const OnGettingTaskCategories(withLoading: true)),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomeNav(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const HomeNav()
        },
      ),
    );
  }
}
