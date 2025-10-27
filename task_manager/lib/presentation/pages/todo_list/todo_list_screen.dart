import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/domain/models/task.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';
import 'package:task_manager/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/filter_button.dart';
import 'package:task_manager/presentation/pages/todo_list/widgets/filter_sort_bottom_sheet.dart';
import 'package:task_manager/presentation/widgets/animated_task_list.dart';
import 'package:task_manager/presentation/widgets/category_selector.dart';
import 'package:task_manager/presentation/widgets/task_list_view.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> taskList = [];
  FilterType activeFilter = FilterType.uncomplete;
  final _categorySelectorKey = GlobalKey<CategorySelectorState>();
  List<int> selectedTaskIds = [];
  String? selectedFormat;
  bool? isCircleCheckbox;

  bool isSelectedPageState = false;
  bool isDeletePressed = false;
  bool? isBulkComplete = false;
  TaskCategory? bulkSelectedCategory;

  @override
  void initState() {
    super.initState();
    activeFilter = FilterType.uncomplete;
    _loadDateFormat();
  }

  Future<void> _loadDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFormat = prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
      isCircleCheckbox = prefs.getBool('isCircleCheckbox') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeColour = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // Filter Buttons and Category Selector
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centers everything horizontally
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Ensures content is centered
                                children: [
                                  FilterButton(
                                    label: "All",
                                    filter: FilterType.uncomplete,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.uncomplete),
                                  ),
                                  const SizedBox(width: 4),
                                  FilterButton(
                                    label: "Late",
                                    filter: FilterType.overdue,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.overdue),
                                  ),
                                  const SizedBox(width: 4),
                                  FilterButton(
                                    label: "Urgent",
                                    filter: FilterType.urgency,
                                    activeFilter: activeFilter,
                                    activeColour: activeColour,
                                    onPressed: () =>
                                        _applyFilter(FilterType.urgency),
                                  ),
                                  const SizedBox(width: 4),
                                  CategorySelector(
                                    key: _categorySelectorKey,
                                    onCategorySelected: (category) {
                                      filterByCategory(category);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // This Spacer pushes the IconButton to the far right
                          IconButton(
                            icon: const Icon(Icons.filter_alt_rounded),
                            color: activeColour,
                            padding: EdgeInsets.zero, // Removes all padding
                            tooltip: 'Filter & Sort',
                            onPressed: () => _openFilterSortPanel(context),
                          ),
                        ],
                      ),
                    ),

                    // Task List
                    Expanded(
                      child: BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, settingsState) {
                          return BlocBuilder<TasksBloc, TasksState>(
                            builder: (context, state) {
                              if (state is LoadingGetTasksState) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (state is SuccessGetTasksState) {
                                return TaskListView(
                                  tasks: state.displayTasks,
                                  dateFormat: settingsState.dateFormat,
                                  isCircleCheckbox:
                                      settingsState.isCircleCheckbox,
                                  onCheckboxChanged: (task) {},
                                  onBulkCategoryChange: (taskIds, category) {
                                    context.read<TasksBloc>().add(
                                        BulkUpdateTasks(
                                            taskIds: List.from(taskIds),
                                            newCategory: category));
                                  },
                                  onBulkComplete: (taskIds, markComplete) {
                                    context.read<TasksBloc>().add(
                                        BulkUpdateTasks(
                                            taskIds: List.from(taskIds),
                                            markComplete: markComplete));
                                  },
                                  onDeleteTasks: (taskIds) {
                                    for (var id in taskIds) {
                                      context
                                          .read<TasksBloc>()
                                          .add(DeleteTask(taskId: id));
                                    }
                                  },
                                );
                              }

                              if (state is NoTasksState) {
                                return const Center(child: Text("No Tasks"));
                              }

                              if (state is ErrorState) {
                                return const Center(
                                    child: Text("An Error Occurred"));
                              }

                              return const Center(child: Text("Unknown Error"));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Overlay Toolbar for Task Selection Mode
        // if (isSelectedPageState)
        //   Positioned(
        //     top: 0,
        //     left: 0,
        //     right: 0,
        //     child: SelectionToolbar(
        //       selectedCount: selectedTaskIds.length,
        //       isDeletePressed: isDeletePressed,
        //       isBulkComplete: isBulkComplete,
        //       bulkSelectedCategory: bulkSelectedCategory,
        //       onDeletePressed: deleteSelectedTasks,
        //       onClosePressed: () {
        //         setState(() {
        //           selectedTaskIds.clear();
        //           isSelectedPageState = false;
        //         });
        //       },
        //       onCategorySelected: (category) {
        //         setState(() {
        //           bulkSelectedCategory = category;
        //         });
        //       },
        //       onBulkCompleteChanged: (value) {
        //         setState(() {
        //           isBulkComplete = value;
        //         });
        //       },
        //       onConfirmPressed: handleBulkActions,
        //     ),
        //   )
      ],
    );
  }

  void _openFilterSortPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FilterSortPanel(
        onFilterChanged: (filter, sortType, category) {
          if (filter != null) {
            context
                .read<TasksBloc>()
                .add(FilterTasks(filter: filter, category: category));
          } else if (sortType != null) {
            context.read<TasksBloc>().add(SortTasks(sortType: sortType));
          }
        },
      ),
    );
  }

  void _applyFilter(FilterType filter) {
    context.read<TasksBloc>().add(FilterTasks(filter: filter));
    setState(() => activeFilter = filter);
    _categorySelectorKey.currentState?.resetCategory();
  }

  void filterByCategory(TaskCategory category) {
    context
        .read<TasksBloc>()
        .add(FilterTasks(filter: FilterType.category, category: category));
    setState(() {
      activeFilter = FilterType.category;
    });
  }
}
