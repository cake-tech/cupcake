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

Future<void> showAlertWidget({
  required BuildContext context,
  required String title,
  required List<Widget> body,
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
            children: body,
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

Future<void> showAlertWidgetMinimal({
  required BuildContext context,
  required List<Widget> body,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: 360,
        child: Material(
          color: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // TODO: Make this look good
            Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: body,
              ),
            ),
          ]),
        ),
      );
    },
  );
}
