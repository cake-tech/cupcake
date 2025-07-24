import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'receive_view_model.g.dart';

class ReceiveViewModel = ReceiveViewModelBase with _$ReceiveViewModel;

abstract class ReceiveViewModelBase extends ViewModel with Store {
  ReceiveViewModelBase(this.wallet);
  final CoinWallet wallet;

  @override
  String get screenName => L.receive;

  @computed
  String get address => wallet.getCurrentAddress;

  @computed
  String get uriScheme => wallet.coin.uriScheme;

  @observable
  bool isFullPage = false;
}
