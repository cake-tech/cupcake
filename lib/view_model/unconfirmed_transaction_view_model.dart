import 'dart:async';

import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';

class Address {
  Address(this.address);
  final String address;

  @override
  String toString() {
    return address;
  }
}

class Amount {
  Amount(this.amount);
  final int amount;

  @override
  String toString() => "$amount";
}

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

  final FutureOr<void> Function(BuildContext context) confirmCallback;
  final FutureOr<void> Function(BuildContext context) cancelCallback;

  final Amount fee;
  final Map<Address, Amount> destMap;
}
