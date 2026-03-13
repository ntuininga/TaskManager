import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/core/theme/color_schemes.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_cubit.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_state.dart';
import 'package:task_manager/presentation/bloc/task_categories/task_categories_bloc.dart';
import 'package:task_manager/presentation/pages/purchase_premium/purchase_premium_page.dart';

class NewCategoryBottomSheet extends StatefulWidget {
  final Set<int> assignedColorValues;

  const NewCategoryBottomSheet({super.key, required this.assignedColorValues});

  @override
  NewCategoryBottomSheetState createState() => NewCategoryBottomSheetState();
}

class NewCategoryBottomSheetState extends State<NewCategoryBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  Color selectedColor = Colors.grey;

  void pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: defaultColors.map((color) {
                final isAssigned =
                    widget.assignedColorValues.contains(color.value);
                return GestureDetector(
                  onTap: () {
                    if (!isAssigned) {
                      setState(() {
                        selectedColor = color;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isAssigned ? color.withOpacity(0.4) : color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black12,
                            width: isAssigned ? 2 : 0,
                          ),
                        ),
                      ),
                      if (isAssigned)
                        const Icon(Icons.close, color: Colors.white, size: 24),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => pickColor(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: titleController,
                    decoration:
                        const InputDecoration(hintText: 'New Category'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;

                    // Re-check limit at save time to guard against race conditions
                    // (e.g. user opened the sheet right at the limit boundary).
                    final premiumState = context.read<PurchaseCubit>().state;
                    final catState = context.read<TaskCategoriesBloc>().state;

                    if (premiumState.status != PurchaseStatusState.premium &&
                        catState is SuccessGetTaskCategoriesState &&
                        catState.allCategories.length >=
                            AppConstants.freeCategoryLimit) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PremiumPage()),
                      );
                      return;
                    }

                    final newCategory = TaskCategory(
                      title: titleController.text.trim(),
                      colour: selectedColor,
                    );
                    context
                        .read<TaskCategoriesBloc>()
                        .add(AddTaskCategory(taskCategoryToAdd: newCategory));
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showNewCategoryBottomSheet(BuildContext context) async {
  // Read all state synchronously before any async gap.
  final currentState = context.read<TaskCategoriesBloc>().state;
  final premiumState = context.read<PurchaseCubit>().state;

  int categoryCount = 0;
  Set<int> assignedColorValues = {};

  if (currentState is SuccessGetTaskCategoriesState) {
    categoryCount = currentState.allCategories.length;
    assignedColorValues = currentState.assignedColors
        .map((color) => color?.toARGB32() ?? 0)
        .toSet();
  }

  // Gate check — redirect to premium page if limit reached.
  if (premiumState.status != PurchaseStatusState.premium &&
      categoryCount >= AppConstants.freeCategoryLimit) {
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPage()),
    );
    return;
  }

  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return NewCategoryBottomSheet(assignedColorValues: assignedColorValues);
    },
  );
}