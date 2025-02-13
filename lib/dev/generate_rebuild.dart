library;

class GenerateRebuild {
  const GenerateRebuild();
}

class RebuildOnChange {
  const RebuildOnChange();
  static const name = 'RebuildOnChange';
}

class ThrowOnUI {
  const ThrowOnUI({this.message, this.L});
  static const name = 'ThrowOnUI';
  final String? L;
  final String? message;
}

class ExposeRebuildableAccessors {
  const ExposeRebuildableAccessors({this.extraCode});
  static const name = 'ExposeRebuildableAccessors';
  final String? extraCode;
}
