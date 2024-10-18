import 'package:cupcake/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class ViewModel {
  String get screenName => "screenName";

  AppLocalizations get L {
    if (_lcache == null && _context == null) {
      throw Exception(
          "context is null in view model. Did you forget to register()?");
    }
    if (_lcache == null && _context?.mounted != true) {
      throw Exception(
          "context is not mounted. Did you register incorrect context?");
    }
    _lcache ??= AppLocalizations.of(_context!);
    return _lcache!;
  }

  AppLocalizations? _lcache;

  BuildContext? _context;
  void register(BuildContext context) {
    _context = context;
  }

  markNeedsBuild() {
    if (_context == null) {
      throw Exception("_context is null, did you forget to register(context)?");
    }
    (_context as Element).markNeedsBuild();
  }
}
