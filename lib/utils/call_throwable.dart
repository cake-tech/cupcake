import 'dart:async';

import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/alert.dart';
import 'package:flutter/cupertino.dart';

Future<void> callThrowable(BuildContext context,
    FutureOr<void> Function() function, String title) async {
  try {
    await function.call();
  } on CoinException catch (e) {
    if (!context.mounted) return;
    await showAlert(
        context: context, title: title, body: [e.details ?? "", e.toString()]);
  } catch (e) {
    if (!context.mounted) return;
    await showAlert(context: context, title: title, body: [e.toString()]);
  }
}
