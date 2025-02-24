import 'package:flutter/material.dart';

Future<void> showAlert({
  required final BuildContext context,
  required final String title,
  required final List<String> body,
  final String ok = "ok",
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (final BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: body
                .map(
                  (final e) => Text(
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
