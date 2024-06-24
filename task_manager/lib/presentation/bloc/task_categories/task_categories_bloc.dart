import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'task_categories_event.dart';
part 'task_categories_state.dart';

class TaskCategoriesBloc extends Bloc<TaskCategoriesEvent, TaskCategoriesState> {
  TaskCategoriesBloc() : super(TaskCategoriesInitial()) {
    on<TaskCategoriesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
