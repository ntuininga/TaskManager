import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_manager/core/notifications/notifications_utils.dart';
import 'package:task_manager/data/datasources/local/dao/task_dao.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:task_manager/presentation/pages/home/home_nav.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injections.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await initializeNotifications();

  checkAllScheduledNotifications();

  final taskDatasource = sl<TaskDatasource>();
  // taskDatasource.handleRecurringTasksOnStartup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TasksBloc>(
          create: (context) => sl<TasksBloc>()
            // ..add(const OnGettingTasksEvent(withLoading: true)),
        ),
        BlocProvider<TaskCategoriesBloc>(
          create: (context) => sl<TaskCategoriesBloc>()
            ..add(const OnGettingTaskCategories(withLoading: true)),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (context) => sl<SettingsBloc>()
          ..add(LoadSettings())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, ThemeMode mode) {
          return MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            home: const HomeNav(),
            routes: <String, WidgetBuilder>{
              '/home': (BuildContext context) => const HomeNav(),
            },
          );
        },
      ),
    );
  }
}
