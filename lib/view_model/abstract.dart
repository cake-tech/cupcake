import 'dart:async';

import 'package:cupcake/coins/abstract/exception.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/alerts/basic.dart';
import 'package:flutter/material.dart';

class ViewModel {
  bool canPop = true;
  String get screenName => "screenName";

  AppLocalizations get L {
    if (_lcache == null && c == null) {
      throw Exception(
          "context is null in view model. Did you forget to register()?");
    }
    if (_lcache == null && c?.mounted != true) {
      throw Exception(
          "context is not mounted. Did you register incorrect context?");
    }
    _lcache ??= AppLocalizations.of(c!);
    return _lcache!;
  }

  BuildContext? _c;

  void register(final BuildContext context) {
    _c = context;
  }

  AppLocalizations? _lcache;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext? get c => _c ?? scaffoldKey.currentContext;
  bool get mounted {
    if (c == null) print("c is null");
    return c?.mounted ?? false;
  }

  void markNeedsBuild() {
    if (c == null) {
      throw Exception("c is null, did you forget to register(context)?");
    }
    (c as Element).markNeedsBuild();
  }

  Future<void> errorHandler(final Object e) =>
      callThrowable(() => throw e, L.create_wallet);

  Future<bool> callThrowable(
      final FutureOr<void> Function() function, final String title) async {
    if (c == null) return false;
    if (!mounted) return false;
    try {
      await function.call();
      return true;
    } on CoinException catch (e) {
      print(e);
      await showAlert(
        context: c!,
        title: title,
        body: [e.details ?? "", e.toString()],
      );
    } on TypeError catch (e) {
      print(e);
      await showAlert(
          context: c!,
          title: title,
          body: [e.toString(), e.stackTrace.toString()]);
    } catch (e) {
      print(e);
      await showAlert(context: c!, title: title, body: [e.toString()]);
    }
    return false;
  }
}
