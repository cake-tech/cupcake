import 'package:flutter/material.dart';

Future<void> showAlertWidget({
  required final BuildContext context,
  required final String title,
  required final List<Widget> body,
  final bool showOk = true,
  final String ok = "ok",
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (final BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xff1B284A),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        alignment: Alignment.center,
        content: SingleChildScrollView(
          child: ListBody(
            children: body,
          ),
        ),
        actions: (showOk)
            ? <Widget>[
                TextButton(
                  child: Text(ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]
            : null,
      );
    },
  );
}
