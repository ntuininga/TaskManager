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
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Widget card = Container(
      // decoration: const BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(color: Colors.black12)
      //   )
      // ),
      child: Center(
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: widget.category.colour,
                shape: BoxShape.circle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.category.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.pop(context, widget.category);
      },
      child: card,
    );
  }
}
