import 'package:cupcake/coins/abstract/address.dart';
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

  @observable
  int currentAddressOffset = 0;

  @computed
  Address get address => wallet.address[currentAddressOffset];

  @computed
  String get uriScheme => wallet.coin.uriScheme;

  @observable
  bool isFullPage = false;
}
