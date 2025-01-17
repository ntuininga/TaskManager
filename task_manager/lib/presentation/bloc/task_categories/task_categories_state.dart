part of 'task_categories_bloc.dart';

sealed class TaskCategoriesState extends Equatable {
  const TaskCategoriesState();

  @override
  List<Object> get props => [];
}

final class TaskCategoriesInitial extends TaskCategoriesState {}

class LoadingGetTaskCategoriesState extends TaskCategoriesState {}

class SuccessGetTaskCategoriesState extends TaskCategoriesState {
  final List<TaskCategory> allCategories;
  final List<Color?> assignedColors;

  const SuccessGetTaskCategoriesState(this.allCategories,
      {required this.assignedColors});

  @override
  List<Object> get props => [allCategories, assignedColors];
}

class NoTaskCategoriesState extends TaskCategoriesState {}

class TaskCategoryErrorState extends TaskCategoriesState {
  final String errorMsg;

  const TaskCategoryErrorState(this.errorMsg);

  @override
  List<Object> get props => [errorMsg];
}

// New state to indicate categories have been updated
class CategoriesUpdatedState extends TaskCategoriesState {
  final List<TaskCategory> updatedCategories;

  const CategoriesUpdatedState(this.updatedCategories);

  @override
  List<Object> get props => [updatedCategories];
}
