import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/barcode_scanner.dart';
import 'package:mobx/mobx.dart';

part 'wallet_home_view_model.g.dart';

class WalletHomeViewModel = WalletHomeViewModelBase with _$WalletHomeViewModel;

abstract class WalletHomeViewModelBase extends ViewModel with Store {
  WalletHomeViewModelBase({required this.wallet});

  final CoinWallet wallet;
  @computed
  Coin get coin => wallet.coin;

  @override
  bool get hasBackground => true;

  @override
  bool get hasPngBackground => true;

  @override
  late String screenName = "Cupcake";

  @computed
  String get balance => wallet.getBalanceString();

  @computed
  Address get currentAddress => wallet.address[0];

  @action
  Future<void> showScanner() {
    return BarcodeScanner(wallet: wallet).push(c!);
  }
}
