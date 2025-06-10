import 'package:cupcake/utils/types.dart';
import 'package:flutter/widgets.dart';

class NewWalletAction {
  NewWalletAction({
    required this.type,
    required this.function,
    required this.text,
    required this.backgroundColor,
  });
  final NewWalletActionType type;
  final VoidCallback? function;
  final Widget text;
  final Color backgroundColor;
}
