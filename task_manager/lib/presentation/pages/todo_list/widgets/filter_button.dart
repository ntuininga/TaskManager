
import 'package:flutter/material.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final FilterType filter;
  final FilterType activeFilter;
  final VoidCallback onPressed;
  final Color activeColour;

  const FilterButton({
    required this.label,
    required this.filter,
    required this.activeFilter,
    required this.onPressed,
    required this.activeColour,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: BorderSide(
          width: 1.5,
          color: activeFilter == filter ? activeColour : Colors.transparent,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
