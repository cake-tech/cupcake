import 'dart:async';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/exception.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/alerts/basic.dart';
import 'package:flutter/material.dart';

abstract class ViewModel {
  bool canPop = true;
  String get screenName => "screenName";

  bool hasBackground = true;
  bool hasPngBackground = false;

  GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get L {
    if (_lcache == null && c == null) {
      throw Exception(
        "context is null in view model. Did you forget to register()?",
      );
    }
    if (_lcache == null && c?.mounted != true) {
      throw Exception(
        "context is not mounted. Did you register incorrect context?",
      );
    }
    _lcache ??= AppLocalizations.of(c!);
    Coin.L = _lcache!;
    return _lcache!;
  }

  ThemeData get T {
    if (_tcache == null && c == null) {
      throw Exception(
        "context is null in view model. Did you forget to register()?",
      );
    }
    if (_tcache == null && c?.mounted != true) {
      throw Exception(
        "context is not mounted. Did you register incorrect context?",
      );
    }
    _tcache ??= Theme.of(c!);
    return _tcache!;
  }

  BuildContext? _c;

  void register(final BuildContext context) {
    _c = context;
  }

  AppLocalizations? _lcache;
  ThemeData? _tcache;

  BuildContext? get c => scaffoldKey.currentContext ?? _c;
  bool get mounted {
    if (c == null) print("c is null");
    return c?.mounted ?? false;
  }

  Future<void> errorHandler(final Object e) => callThrowable(() => throw e, L.create_wallet);

  Future<bool> callThrowable(
    final Future<void> Function() function,
    final String title,
  ) async {
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
        body: [e.toString(), e.stackTrace.toString()],
      );
    } catch (e) {
      print(e);
      await showAlert(context: c!, title: title, body: [e.toString()]);
    }
    return false;
  }
}
