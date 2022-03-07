import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class WarningLessonDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          localizations.getLocalization("warning"),
          textScaleFactor: 1.0,
          style: TextStyle(color: Colors.black, fontSize: 20.0)
      ),
      content: Text(
        localizations.getLocalization("warning_lesson_offline"),
        textScaleFactor: 1.0,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            localizations.getLocalization("ok_dialog_button"),
            textScaleFactor: 1.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

}
