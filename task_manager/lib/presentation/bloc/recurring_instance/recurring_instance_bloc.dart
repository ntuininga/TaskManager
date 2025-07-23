import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/domain/models/recurring_instance.dart';
import 'package:task_manager/domain/repositories/recurring_instance_repository.dart';

part 'recurring_instance_event.dart';
part 'recurring_instance_state.dart';

class RecurringInstanceBloc
    extends Bloc<RecurringInstanceEvent, RecurringInstanceState> {
  final RecurringInstanceRepository recurringInstanceRepository;

  RecurringInstanceBloc({
    required this.recurringInstanceRepository,
  }) : super(RecurringInstanceInitial()) {
    on<RecurringInstanceEvent>((event, emit) {});
    on<CompleteRecurringInstance>(_onCompleteRecurringInstance);
  }

  void _onCompleteRecurringInstance(CompleteRecurringInstance event,
      Emitter<RecurringInstanceState> emit) async {
    try {
      final instance = event.instance;
      int updatedInstanceId = await recurringInstanceRepository
          .completeInstance(instance.id!, DateTime.now());
      
    } catch (e) {
      emit(ErrorState("Unable to complete recurring instance"));
    }
  }
}
