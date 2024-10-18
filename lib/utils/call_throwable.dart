import 'dart:async';

import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/utils/alert.dart';
import 'package:flutter/cupertino.dart';

Future<bool> callThrowable(BuildContext context,
    FutureOr<void> Function() function, String title) async {
  try {
    await function.call();
    return true;
  } on CoinException catch (e) {
    print(e);
    if (!context.mounted) return false;
    await showAlert(
        context: context, title: title, body: [e.details ?? "", e.toString()]);
  } on TypeError catch (e) {
    print(e);
    if (!context.mounted) return false;
    await showAlert(
        context: context,
        title: title,
        body: [e.toString(), e.stackTrace.toString()]);
  } catch (e) {
    print(e);
    if (!context.mounted) return false;
    await showAlert(context: context, title: title, body: [e.toString()]);
  }
  return false;
}
