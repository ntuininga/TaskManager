part of 'task_categories_bloc.dart';

sealed class TaskCategoriesState extends Equatable {
  const TaskCategoriesState();
  
  @override
  List<Object> get props => [];
}

final class TaskCategoriesInitial extends TaskCategoriesState {}
