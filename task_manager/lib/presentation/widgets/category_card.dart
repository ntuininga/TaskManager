import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';

class CategoryCard extends StatelessWidget {
  final TaskCategory? category;

  const CategoryCard({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjust vertical spacing
      child: Material(
        color: Colors.transparent, // Keeps background unchanged
        child: InkWell(
          onTap: () {
            Navigator.pop(context, category);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0), // Increases tap area without altering size
            child: Row(
              children: [
                // Circle with category color
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: category != null
                        ? category!.colour
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                // Category title with overflow handling
                Expanded(
                  child: Text(
                    category != null
                        ? category!.title ?? "No Title"
                        : "No Category",
                    style: const TextStyle(
                      fontSize: 15, // Keeps font size the same
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Handles long text gracefully
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
