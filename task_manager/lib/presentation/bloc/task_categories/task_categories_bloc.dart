import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';
import 'package:task_manager/domain/usecases/task_categories/add_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/update_task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/delete_task_category.dart';

part 'task_categories_event.dart';
part 'task_categories_state.dart';

class TaskCategoriesBloc extends Bloc<TaskCategoriesEvent, TaskCategoriesState> {
  final GetTaskCategoriesUseCase getTaskCategoriesUseCase;
  final AddTaskCategoryUseCase addTaskCategoryUseCase;
  final UpdateTaskCategoryUseCase updateTaskCategoryUseCase;
  final DeleteTaskCategoryUseCase deleteTaskCategoryUseCase;

  TaskCategoriesBloc({
    required this.getTaskCategoriesUseCase,
    required this.addTaskCategoryUseCase,
    required this.updateTaskCategoryUseCase,
    required this.deleteTaskCategoryUseCase,
  }) : super(LoadingGetTaskCategoriesState()) {
    on<OnGettingTaskCategories>(_onGettingTaskCategoriesEvent);
    on<AddTaskCategory>(_onAddTaskCategoryEvent);
    on<UpdateTaskCategory>(_onUpdateTaskCategoryEvent);
    on<DeleteTaskCategory>(_onDeleteTaskCategoryEvent);
  }

  Future<void> _refreshTaskCategories(Emitter<TaskCategoriesState> emitter) async {
    try {
      final result = await getTaskCategoriesUseCase.call();

      if (result.isNotEmpty) {
        emitter(SuccessGetTaskCategoriesState(result));
      } else {
        emitter(NoTaskCategoriesState());
      }
    } catch (e) {
      emitter(TaskCategoryErrorState(e.toString()));
    }
  }

  Future<void> _onGettingTaskCategoriesEvent(
      OnGettingTaskCategories event, Emitter<TaskCategoriesState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTaskCategoriesState());
    }

    await _refreshTaskCategories(emitter);
  }

  Future<void> _onAddTaskCategoryEvent(
      AddTaskCategory event, Emitter<TaskCategoriesState> emitter) async {
    try {
      await addTaskCategoryUseCase.call(event.taskCategoryToAdd);
      await _refreshTaskCategories(emitter);
    } catch (e) {
      emitter(TaskCategoryErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTaskCategoryEvent(
      UpdateTaskCategory event, Emitter<TaskCategoriesState> emitter) async {
    try {
      await updateTaskCategoryUseCase.call(event.taskCategoryToUpdate);
      await _refreshTaskCategories(emitter);
    } catch (e) {
      emitter(TaskCategoryErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTaskCategoryEvent(
      DeleteTaskCategory event, Emitter<TaskCategoriesState> emitter) async {
    try {
      await deleteTaskCategoryUseCase.call(event.id);
      await _refreshTaskCategories(emitter);
    } catch (e) {
      emitter(TaskCategoryErrorState(e.toString()));
    }
  }
}
