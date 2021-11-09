import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AutoUpdateDialog extends StatefulWidget {
  String message;
  Function onOkayPressed;

  AutoUpdateDialog({
    this.message,
    this.onOkayPressed,
  });

  @override
  _AutoUpdateDialogState createState() => new _AutoUpdateDialogState();
}

class _AutoUpdateDialogState extends State<AutoUpdateDialog> {

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.message,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style:
                Theme.of(context).textTheme.button.copyWith(
                  color:  Colors.blue[800],
                  fontWeight: FontWeight.w700,
                ),
          ),
          onPressed: () {
            widget.onOkayPressed();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
