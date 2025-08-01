import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/connect_wallet.dart';
import 'package:mobx/mobx.dart';

part 'connect_wallet_view_model.g.dart';

class ConnectWalletViewModel = ConnectWalletViewModelBase with _$ConnectWalletViewModel;

abstract class ConnectWalletViewModelBase extends ViewModel with Store {
  ConnectWalletViewModelBase({
    required this.wallet,
    required this.canSkip,
    this.isShowingInfo = true,
  });

  final CoinWallet wallet;

  @observable
  bool canSkip;

  final bool isShowingInfo;

  void setIsShowingInfo(final bool value) {
    ConnectWallet(wallet: wallet, canSkip: canSkip, isShowingInfo: value).push(c!);
  }

  @override
  String get screenName => isShowingInfo ? L.link_to_cakewallet : L.restore_wallet;

  @computed
  List<String> get syncQRCode => wallet.connectCakeWalletQRCode;
}
