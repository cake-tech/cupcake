import 'package:cup_cake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

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
    required this.lottieAnimation,
    required this.actions,
    required this.texts,
  });

  final String topText;
  final VoidCallback? topAction;
  final Widget? topActionText;

  final LottieBuilder? lottieAnimation;
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
