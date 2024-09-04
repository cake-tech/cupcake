import 'package:flutter/cupertino.dart';

class ViewModel {
  String get screenName => "screenName";

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
