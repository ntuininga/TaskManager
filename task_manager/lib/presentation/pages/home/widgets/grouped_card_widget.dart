import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';

class GroupedCardWidget extends StatelessWidget {
  final TaskCategory? category;
  final String? title;
  final Color? color;
  final int categoryTaskCount;
  final VoidCallback? onTap;

  const GroupedCardWidget({
    super.key,
    this.category,
    this.title,
    this.color,
    required this.categoryTaskCount,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardTitle = title ?? category?.title ?? 'Untitled Category';
    final cardColor = color ?? category?.colour ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
          border: Border(
            left: BorderSide(color: cardColor, width: 5.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cardTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                categoryTaskCount.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
