import 'package:flutter/material.dart';

class NewCategoryBottomSheet extends StatelessWidget {
  NewCategoryBottomSheet({super.key});

  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: titleController,
                    decoration: const InputDecoration(hintText: "New Category"),
                  ),
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
  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return NewCategoryBottomSheet();
    },
  );
}
