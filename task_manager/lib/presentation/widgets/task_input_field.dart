import 'package:flutter/material.dart';

class TaskInputField extends StatelessWidget {
  final Widget child;
  final double? borderWidth;

  const TaskInputField({Key? key, required this.child, this.borderWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: borderWidth ?? 1,
              color: borderWidth == 0
                  ? Colors.transparent
                  : Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child),
        ],
      ),
    );
  }
}