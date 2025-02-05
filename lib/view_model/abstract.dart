import 'package:cupcake/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class ViewModel {
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

  AppLocalizations? _lcache;

  BuildContext? c;
  void register(BuildContext context) {
    c = context;
  }

  bool get mounted => c?.mounted??false;

  markNeedsBuild() {
    if (c == null) {
      throw Exception("c is null, did you forget to register(context)?");
    }
    (c as Element).markNeedsBuild();
  }
}
