part of 'task_categories_bloc.dart';

sealed class TaskCategoriesEvent extends Equatable {
  const TaskCategoriesEvent();

  @override
  List<Object> get props => [];
}

class OnGettingTaskCategories extends TaskCategoriesEvent {
  final bool withLoading;

  const OnGettingTaskCategories({required this.withLoading});

  @override
  List<Object> get props => [withLoading];
}

class AddTaskCategory extends TaskCategoriesEvent {
  final TaskCategory taskCategoryToAdd;

  const AddTaskCategory({required this.taskCategoryToAdd});

  @override
  List<Object> get props => [taskCategoryToAdd];
}

class UpdateTaskCategory extends TaskCategoriesEvent {
  final TaskCategory taskCategoryToUpdate;

  const UpdateTaskCategory({required this.taskCategoryToUpdate});

  @override
  List<Object> get props => [taskCategoryToUpdate];
}

class DeleteTaskCategory extends TaskCategoriesEvent {
  final int id;

  const DeleteTaskCategory({required this.id});

  @override
  List<Object> get props => [id];
}
