import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/task_categories/add_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/update_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';
import 'package:task_manager/presentation/bloc/all_tasks/tasks_bloc.dart';

part 'task_categories_event.dart';
part 'task_categories_state.dart';

class TaskCategoriesBloc
    extends Bloc<TaskCategoriesEvent, TaskCategoriesState> {
  final GetTaskCategoriesUseCase getTaskCategoriesUseCase;
  final AddTaskCategoryUseCase addTaskCategoryUseCase;
  final UpdateTaskCategoryUseCase updateTaskCategoryUseCase;
  final DeleteTaskCategoryUseCase deleteTaskCategoryUseCase;
  final TasksBloc tasksBloc; // Add TasksBloc dependency

  TaskCategoriesBloc({
    required this.getTaskCategoriesUseCase,
    required this.addTaskCategoryUseCase,
    required this.updateTaskCategoryUseCase,
    required this.deleteTaskCategoryUseCase,
    required this.tasksBloc,
  }) : super(LoadingGetTaskCategoriesState()) {
    on<OnGettingTaskCategories>(_onGettingTaskCategoriesEvent);
    on<AddTaskCategory>(_onAddTaskCategoryEvent);
    on<UpdateTaskCategory>(_onUpdateTaskCategoryEvent);
    on<DeleteTaskCategory>(_onDeleteTaskCategoryEvent);
  }

  Future<void> _refreshTaskCategories(Emitter<TaskCategoriesState> emit) async {
    try {
      final result = await getTaskCategoriesUseCase.call();

      // Filter out the color for "No Categories"
      final assignedColors = result
          .map((category) => category.colour)
          .where((color) => color != Colors.grey)
          .toSet()
          .toList();

      if (result.isNotEmpty) {
        emit(SuccessGetTaskCategoriesState(result, assignedColors: assignedColors));
      } else {
        emit(NoTaskCategoriesState());
      }
    } catch (e) {
      emit(TaskCategoryErrorState(e.toString()));
    }
  }



  Future<void> _onGettingTaskCategoriesEvent(
      OnGettingTaskCategories event, Emitter<TaskCategoriesState> emit) async {
    if (event.withLoading) {
      emit(LoadingGetTaskCategoriesState());
    }

    await _refreshTaskCategories(emit);
  }

  Future<void> _onAddTaskCategoryEvent(
      AddTaskCategory event, Emitter<TaskCategoriesState> emit) async {
    try {
      await addTaskCategoryUseCase.call(event.taskCategoryToAdd);
      await _refreshTaskCategories(emit);
    } catch (e) {
      emit(TaskCategoryErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTaskCategoryEvent(
      UpdateTaskCategory event, Emitter<TaskCategoriesState> emit) async {
    try {
      await updateTaskCategoryUseCase.call(event.taskCategoryToUpdate);

      // Trigger tasks update in TasksBloc
      tasksBloc.add(CategoryChangeEvent(event.taskCategoryToUpdate, event.taskCategoryToUpdate.id));

      await _refreshTaskCategories(emit);
    } catch (e) {
      emit(TaskCategoryErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTaskCategoryEvent(
      DeleteTaskCategory event, Emitter<TaskCategoriesState> emit) async {
    try {
      await deleteTaskCategoryUseCase.call(event.id);

      tasksBloc.add(CategoryChangeEvent(null, event.id));

      await _refreshTaskCategories(emit);
    } catch (e) {
      emit(TaskCategoryErrorState(e.toString()));
    }
  }
}
