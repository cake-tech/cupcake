library;

class GenerateRebuild {
  const GenerateRebuild();
}

class RebuildOnChange {
  static const name = 'RebuildOnChange';
  const RebuildOnChange();
}

class ThrowOnUI {
  static const name = 'ThrowOnUI';
  final String? L;
  final String? message;
  const ThrowOnUI({this.message, this.L});
}

class ExposeRebuildableAccessors {
  static const name = 'ExposeRebuildableAccessors';
  final String? extraCode;
  const ExposeRebuildableAccessors({this.extraCode});
}
