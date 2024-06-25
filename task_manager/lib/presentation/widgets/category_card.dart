import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';

class CategoryCard extends StatefulWidget {
  final TaskCategory category;

  const CategoryCard({required this.category, super.key});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      surfaceTintColor: widget.category.colour,
      child: Center(
        child: Text(widget.category.title),
      ),
    );

    return GestureDetector(
        onTap: () {
          Navigator.pop(context, widget.category);
        },
        child: card);
  }
}
