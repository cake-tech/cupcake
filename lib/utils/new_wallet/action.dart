import 'package:cupcake/utils/types.dart';
import 'package:flutter/widgets.dart';

class NewWalletAction {
  NewWalletAction({
    required this.type,
    required this.function,
    required this.text,
  });
  final NewWalletActionType type;
  final Function(BuildContext context)? function;
  final String text;
}
