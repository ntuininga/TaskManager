import 'package:flutter/material.dart';
import 'package:task_manager/presentation/bloc/tasks_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestListScreen extends StatelessWidget {
  const TestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  _buildBody() {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (_, state) {
        if (state is LoadingGetTasksState){
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SuccessGetTasksState) {
          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              return Text(state.tasks[index].title);
            },
          );
        }
        return const SizedBox();
      },
    );

  }
}