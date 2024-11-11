import 'package:flutter/material.dart';


// snack bar builder to have it the same everywhere
void showSnackBar(BuildContext context, Widget content, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.deepOrangeAccent,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      behavior: SnackBarBehavior.floating,
      content: content,
      action: action,
    ),
  );
}
