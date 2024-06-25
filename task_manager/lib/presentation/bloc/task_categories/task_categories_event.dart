part of 'task_categories_bloc.dart';

sealed class TaskCategoriesEvent extends Equatable {
  const TaskCategoriesEvent();

  @override
  List<Object> get props => [];
}

class OnGettingTaskCategories extends TaskCategoriesEvent {
  final bool withLoading;

  const OnGettingTaskCategories({required this.withLoading});
}

class AddTaskCategory extends TaskCategoriesEvent {
  final TaskCategory taskCategoryToAdd;

  const AddTaskCategory({required this.taskCategoryToAdd});
}

class UpdateTaskCategory extends TaskCategoriesEvent {
  final TaskCategory taskCategoryToUpdate;

  const UpdateTaskCategory({required this.taskCategoryToUpdate});
}

class DeleteTaskCategory extends TaskCategoriesEvent {
  final int id;

  const DeleteTaskCategory({required this.id});
}