import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'ui_playground_view_model.g.dart';

class UIPlaygroundViewModel = UIPlaygroundViewModelBase with _$UIPlaygroundViewModel;

abstract class UIPlaygroundViewModelBase extends ViewModel with Store {
  UIPlaygroundViewModelBase({required this.wallet});

  @override
  String get screenName => "UI Playground";

  final CoinWallet wallet;
}
