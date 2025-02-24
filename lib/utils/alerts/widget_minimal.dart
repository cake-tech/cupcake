import 'package:flutter/material.dart';

Future<void> showAlertWidgetMinimal({
  required final BuildContext context,
  required final List<Widget> body,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (final BuildContext context) {
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
