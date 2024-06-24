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

  const SuccessGetTaskCategoriesState(this.allCategories);

  @override
  List<Object> get props => [allCategories];
}

class NoTaskCategoriesState extends TaskCategoriesState {}

class TaskCategoryErrorState extends TaskCategoriesState {
  final String errorMsg;

  const TaskCategoryErrorState(this.errorMsg);
}
