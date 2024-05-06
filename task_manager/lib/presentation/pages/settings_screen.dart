import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/widgets/delete_confirmation_dialog.dart';

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
              await taskRepository.deleteAllTasks();
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
    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text("Data"),
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
    );
  }
}
