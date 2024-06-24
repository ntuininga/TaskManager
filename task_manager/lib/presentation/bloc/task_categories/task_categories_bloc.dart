import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/task_category.dart';
import 'package:task_manager/domain/usecases/task_categories/get_task_categories.dart';

part 'task_categories_event.dart';
part 'task_categories_state.dart';

class TaskCategoriesBloc
    extends Bloc<TaskCategoriesEvent, TaskCategoriesState> {
  final GetTaskCategoriesUseCase getTaskCategoriesUseCase;
  TaskCategoriesBloc({required this.getTaskCategoriesUseCase})
      : super(LoadingGetTaskCategoriesState()) {
    on<OnGettingTaskCategories>(_onGettingTaskCategoriesEvent);
  }

  Future<void> _refreshTaskCategories(
      Emitter<TaskCategoriesState> emitter) async {
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

  Future<void> _onGettingTaskCategoriesEvent(OnGettingTaskCategories event,
      Emitter<TaskCategoriesState> emitter) async {
    if (event.withLoading) {
      emitter(LoadingGetTaskCategoriesState());
    }

    await _refreshTaskCategories(emitter);
  }
}
