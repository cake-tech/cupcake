import 'package:flutter/material.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: body,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
