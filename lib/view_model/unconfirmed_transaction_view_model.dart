import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'unconfirmed_transaction_view_model.g.dart';

class UnconfirmedTransactionViewModel = UnconfirmedTransactionViewModelBase
    with _$UnconfirmedTransactionViewModel;

abstract class UnconfirmedTransactionViewModelBase extends ViewModel with Store {
  UnconfirmedTransactionViewModelBase({
    required this.wallet,
    required this.fee,
    required this.destMap,
    required final FutureOr<void> Function(BuildContext context) confirmCallback,
    required final FutureOr<void> Function() cancelCallback,
  })  : _confirmCallback = confirmCallback,
        _cancelCallback = cancelCallback;

  final CoinWallet wallet;

  @override
  late String screenName = wallet.coin.strings.nameFull;

  final FutureOr<void> Function(BuildContext context) _confirmCallback;
  final FutureOr<void> Function() _cancelCallback;

  Future<void> confirm(final BuildContext context) => callThrowable(
        () async => await _confirmCallback(context),
        L.error_unable_to_confirm_transaction,
      );
  Future<void> cancel() => callThrowable(
        () async => await _cancelCallback(),
        L.error_unable_to_cancel,
      );

  final Amount fee;
  final Map<Address, Amount> destMap;
}
