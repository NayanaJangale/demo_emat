import 'package:flutter/material.dart';

class UserMessageHandler {
  static void showMessage(
    GlobalKey<ScaffoldState> globalKey,
    String textToBeShown,
    Color color,
  ) {
    globalKey.currentState.showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: new Text(textToBeShown),
        duration: Duration(
          seconds: 6,
        ),
      ),
    );
  }
}
