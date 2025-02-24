import 'package:flutter/material.dart';

class DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const DescriptionField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Start in editing mode if there's already text
    isEditing = widget.controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.dividerColor;

    return isEditing
        ? Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus && widget.controller.text.isEmpty) {
                setState(() {
                  isEditing = false;
                });
              }
            },
            child: TextField(
              autofocus: true,
              controller: widget.controller,
              focusNode: widget.focusNode,
              decoration: const InputDecoration(
                label: Text("Description"),
                hintText: 'Enter description...',
                border: OutlineInputBorder(),
              ),
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                setState(() => isEditing = true);
                Future.delayed(Duration.zero, () {
                  widget.focusNode.requestFocus();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notes_rounded, size: 24, color: textColor),
                  const SizedBox(width: 4),
                  Text(
                    "Description",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
          );
  }
}
