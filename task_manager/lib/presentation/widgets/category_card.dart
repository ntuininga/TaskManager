import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';

class CategoryCard extends StatefulWidget {
  final TaskCategory? category;

  const CategoryCard({required this.category, super.key});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    Widget card = Center(
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: widget.category != null
                  ? widget.category!.colour
                  : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.category != null ? widget.category!.title! : "No Category",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        print(widget.category);
        Navigator.pop(context, widget.category);
      },
      child: card,
    );
  }
}
