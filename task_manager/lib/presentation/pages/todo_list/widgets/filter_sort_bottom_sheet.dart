import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/pages/edit_task/widgets/category_dropdown.dart';

class FilterSortPanel extends StatefulWidget {
  final Function(FilterType?, SortType?, TaskCategory?)
      onFilterChanged; // Callback with both filter and category

  const FilterSortPanel({Key? key, required this.onFilterChanged})
      : super(key: key);

  @override
  FilterSortPanelState createState() => FilterSortPanelState();
}

class FilterSortPanelState extends State<FilterSortPanel> {
  TaskCategory? selectedCategory;
  FilterType? activeFilter;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: controller,
          children: [
            const Text("Filter",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ...FilterType.values
                    .where((filter) => filter != FilterType.category)
                    .map((filter) {
                  return ChoiceChip(
                    label: Text(filter.displayName),
                    selected: activeFilter == filter,
                    onSelected: (value) {
                      setState(() {
                        activeFilter = filter;
                      });
                      // Notify parent widget of the filter change
                      widget.onFilterChanged(filter, null, selectedCategory);
                    },
                  );
                }).toList(),
                CategoryDropdown(
                  selectedCategory: selectedCategory,
                  onChanged: (category) {
                    setState(() {
                      selectedCategory = category;
                      activeFilter = FilterType.category;
                    });
                    // Notify parent widget of the category filter change
                    widget.onFilterChanged(FilterType.category, null, category);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Sort",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text("Sort by Date"),
              leading: const Icon(Icons.calendar_today),
              onTap: () {
                widget.onFilterChanged(null, SortType.date, null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Sort by Urgency"),
              leading: const Icon(Icons.priority_high),
              onTap: () {
                widget.onFilterChanged(null, SortType.urgency, null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
