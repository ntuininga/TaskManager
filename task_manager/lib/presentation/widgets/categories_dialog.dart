import 'package:flutter/material.dart';
import 'package:task_manager/core/data/app_database.dart';
import 'package:task_manager/models/task_category.dart';
import 'package:task_manager/presentation/widgets/new_task_category_bottom_sheet.dart';

class CategoryDialog extends StatefulWidget {
  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final db = AppDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Category'),
      content: FutureBuilder<List<TaskCategory?>>(
        future: db.fetchAllTaskCategories(),
        builder: (BuildContext context, AsyncSnapshot<List<TaskCategory?>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No categories found.');
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 100,
                  width: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      TaskCategory category = snapshot.data![index]!;
                      return ListTile(
                        title: Text(category.title),
                        onTap: () {
                          // Do something with the selected category
                          Navigator.of(context).pop(category);
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    showNewTaskCategoryBottomSheet(context, (){setState(() {
                      
                    });});
                  }, 
                  child: const Icon(Icons.add))
              ],
            );
          }
        },
      ),
    );
  }
}
