import 'package:flutter/material.dart';

Future<void> showAlert({
  required BuildContext context,
  required String title,
  required List<String> body,
  String ok = "ok",
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: body
                .map(
                  (e) => Text(
                    e,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                .toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
