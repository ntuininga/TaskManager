import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/category_manager.dart';
import 'package:task_manager/presentation/widgets/Dialogs/delete_confirmation_dialog.dart';
import 'package:task_manager/presentation/widgets/Dialogs/theme_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirmed: () async {
            try {
              context.read<TasksBloc>().add(DeleteAllTasks());
            } catch (e) {
              print('Error: $e');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).canvasColor),
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Text("Manage Categories"),
                description: const Text("Manage all task categories"),
                leading: const Icon(Icons.category),
                onPressed:(context) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoryManager()));
                },)
            ]
          ),
          SettingsSection(
            title: const Text("Theme"),
            tiles: [
              SettingsTile(
                title: const Text("Theme"),
                description: const Text("Change app theme"),
                leading: const Icon(Icons.palette),
                onPressed: (context) {
                  showThemeDialog(context);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text("User Data"),
            tiles: [
              SettingsTile(
                title: const Text("Clear Tasks"),
                description: const Text("Permanently delete all created tasks"),
                leading: const Icon(Icons.delete),
                onPressed: (context) {
                  _showDeleteConfirmationDialog();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
