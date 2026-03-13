import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_cubit.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_state.dart';
import 'package:task_manager/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:task_manager/presentation/pages/category_manager.dart';
import 'package:task_manager/presentation/pages/purchase_premium/purchase_premium_page.dart';
import 'package:task_manager/presentation/widgets/Dialogs/delete_confirmation_dialog.dart';
import 'package:task_manager/presentation/widgets/Dialogs/theme_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TaskRepository taskRepository = GetIt.instance<TaskRepository>();

  final List<String> dateFormats = [
    'MM-dd-yyyy',
    'dd-MM-yyyy',
    'yyyy-MM-dd',
    'EEE, MMM d',
    'MMMM d, yyyy',
  ];

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirmed: () async {
            try {
              context.read<TasksBloc>().add(DeleteAllTasks());
            } catch (e) {
              debugPrint('Error deleting tasks: $e');
            }
          },
        );
      },
    );
  }

  Future<void> _requestPermissions(BuildContext context) async {
    final permissionStatus = await Permission.notification.status;

    if (!context.mounted) return;

    if (permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission already granted')),
      );
    } else if (permissionStatus.isDenied) {
      final permissionRequestStatus = await Permission.notification.request();
      if (!context.mounted) return;

      if (permissionRequestStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission granted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification permission denied.'),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification permission is permanently denied.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
    }
  }

 void _showDateFormatDialog(String currentFormat) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text("Choose Date Format"),
        children: [
          RadioGroup<String>(
            groupValue: currentFormat,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsBloc>().add(UpdateDateFormat(value));
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: dateFormats.map((format) {
                return RadioListTile<String>(
                  value: format,
                  title: Text(DateFormat(format).format(DateTime.now())),
                );
              }).toList(),
            ),
          ),
        ],
      );
    },
  );
}

void _showTaskIndicatorDialog(bool isCircleCheckbox) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Task Indicator Style'),
        content: RadioGroup<bool>(
          groupValue: isCircleCheckbox,
          onChanged: (value) {
            if (value != null) {
              context.read<SettingsBloc>().add(UpdateCheckboxFormat(value));
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<bool>(
                title: Text('Checkbox'),
                value: false,
              ),
              RadioListTile<bool>(
                title: Text('Circle'),
                value: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return BlocConsumer<PurchaseCubit, PurchaseState>(
            listener: (context, purchaseState) {
              // Show error snackbar for any purchase/restore failure
              if (purchaseState.status == PurchaseStatusState.error &&
                  purchaseState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(purchaseState.error!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // Show success snackbar when premium is restored
              if (purchaseState.status == PurchaseStatusState.premium) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Premium restored successfully!'),
                  ),
                );
              }
            },
            builder: (context, purchaseState) {
              final isPremium =
                  purchaseState.status == PurchaseStatusState.premium;
              final isRestoring =
                  purchaseState.status == PurchaseStatusState.loading;

              return SettingsList(
                lightTheme: SettingsThemeData(
                  settingsListBackground: Theme.of(context).canvasColor,
                ),
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile(
                        title: const Text("Manage Categories"),
                        description:
                            const Text("Manage all task categories"),
                        leading: const Icon(Icons.category),
                        onPressed: (context) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const CategoryManager()));
                        },
                      ),
                    ],
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
                      SettingsTile.navigation(
                        title: const Text("Date Format"),
                        description: Text(
                          DateFormat(settingsState.dateFormat)
                              .format(DateTime.now()),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        onPressed: (_) =>
                            _showDateFormatDialog(settingsState.dateFormat),
                      ),
                      SettingsTile.navigation(
                        title: const Text("Checkbox Style"),
                        description: Text(
                          settingsState.isCircleCheckbox
                              ? "Circle"
                              : "Checkbox",
                        ),
                        leading: const Icon(Icons.check_circle_outline),
                        onPressed: (_) => _showTaskIndicatorDialog(
                            settingsState.isCircleCheckbox),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text("User Data"),
                    tiles: [
                      SettingsTile(
                        title: const Text("Clear Tasks"),
                        description: const Text(
                            "Permanently delete all created tasks"),
                        leading: const Icon(Icons.delete),
                        onPressed: (context) {
                          _showDeleteConfirmationDialog();
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text("Permissions"),
                    tiles: [
                      SettingsTile(
                        title: const Text("Notification Permissions"),
                        description:
                            const Text("Allow app to send notifications"),
                        leading: const Icon(Icons.notifications),
                        onPressed: (context) {
                          _requestPermissions(context);
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: const Text("Purchases"),
                    tiles: [
                      SettingsTile(
                        title: const Text("Premium"),
                        description: Text(
                          isPremium
                              ? "✓ You have Premium"
                              : "Unlock all premium features",
                        ),
                        leading: Icon(
                          Icons.workspace_premium,
                          color: isPremium ? Colors.amber : null,
                        ),
                        // Disabled if already premium or a restore is in progress
                        onPressed: (isPremium || isRestoring)
                            ? null
                            : (context) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const PremiumPage()));
                              },
                      ),
                      // Only show restore tile if not already premium
                      if (!isPremium)
                        SettingsTile(
                          title: Text(
                            isRestoring
                                ? "Restoring..."
                                : "Restore Purchase",
                          ),
                          description: const Text(
                            "Already purchased? Tap to restore",
                          ),
                          leading: isRestoring
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.restore),
                          onPressed: isRestoring
                              ? null
                              : (context) {
                                  context
                                      .read<PurchaseCubit>()
                                      .restorePurchases();
                                },
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}