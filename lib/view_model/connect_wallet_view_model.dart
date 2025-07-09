import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'connect_wallet_view_model.g.dart';

class ConnectWalletViewModel = ConnectWalletViewModelBase with _$ConnectWalletViewModel;

abstract class ConnectWalletViewModelBase extends ViewModel with Store {
  ConnectWalletViewModelBase({required this.wallet});

  final CoinWallet wallet;

  @observable
  bool isShowingInfo = true;

  @override
  String get screenName => "Restore Wallet";

  @computed
  List<String> get syncQRCode => wallet.connectCakeWalletQRCode;
}
