import 'package:flutter/material.dart';

Future<void> showCategoriesDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Categories"),
        );
      });
}
