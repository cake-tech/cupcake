import 'package:cup_cake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';

enum NewWalletActionType {
  nextPage,
  function,
}

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

class NewWalletInfoPage {
  NewWalletInfoPage({
    required this.topText,
    required this.topAction,
    required this.topActionText,
    required this.lottieAnimationAsset,
    required this.actions,
    required this.texts,
  });

  final String topText;
  final VoidCallback? topAction;
  final Widget? topActionText;

  final String? lottieAnimationAsset;
  final List<NewWalletAction> actions;

  List<Widget> texts;
}

class NewWalletInfoViewModel extends ViewModel {
  NewWalletInfoViewModel(this.pages);

  @override
  String get screenName => page.topText;

  NewWalletInfoPage get page => pages[currentPageIndex];

  List<NewWalletInfoPage> pages;
  int currentPageIndex = 0;

  void nextPage() {
    currentPageIndex++;
    markNeedsBuild();
  }
}
