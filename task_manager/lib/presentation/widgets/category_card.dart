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
    return GestureDetector(
      onTap: () {
        print(widget.category);
        Navigator.pop(context, widget.category);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding as needed
        child: Row(
          children: [
            // Circle with category color
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: widget.category != null
                    ? widget.category!.colour
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            // Category title with overflow handling
            Expanded(
              child: Text(
                widget.category != null
                    ? widget.category!.title ?? "No Title"
                    : "No Category",
                style: const TextStyle(
                  fontSize: 14, // Adjust font size as needed
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis, // Handles long text with ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }
}
