import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/view_model/abstract.dart';

class UnconfirmedTransactionViewModel extends ViewModel {
  UnconfirmedTransactionViewModel(
      {required this.wallet,
      required this.fee,
      required this.destMap,
      required this.confirmCallback,
      required this.cancelCallback});

  final CoinWallet wallet;

  @override
  late String screenName = wallet.coin.strings.nameFull;

  final FutureOr<void> Function() confirmCallback;
  final FutureOr<void> Function() cancelCallback;

  final Amount fee;
  final Map<Address, Amount> destMap;
}
