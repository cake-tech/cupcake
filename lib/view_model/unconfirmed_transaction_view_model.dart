import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'unconfirmed_transaction_view_model.g.dart';

class UnconfirmedTransactionViewModel = UnconfirmedTransactionViewModelBase
    with _$UnconfirmedTransactionViewModel;

abstract class UnconfirmedTransactionViewModelBase with ViewModel, Store {
  UnconfirmedTransactionViewModelBase({
    required this.wallet,
    required this.fee,
    required this.destMap,
    required final FutureOr<void> Function() confirmCallback,
    required final FutureOr<void> Function() cancelCallback,
  })  : _confirmCallback = confirmCallback,
        _cancelCallback = cancelCallback;

  final CoinWallet wallet;

  @override
  late String screenName = wallet.coin.strings.nameFull;

  final FutureOr<void> Function() _confirmCallback;
  final FutureOr<void> Function() _cancelCallback;

  Future<void> confirm() => callThrowable(
        () async => await _confirmCallback(),
        L.error_unable_to_confirm_transaction,
      );
  Future<void> cancel() => callThrowable(
        () async => await _cancelCallback(),
        L.error_unable_to_cancel,
      );

  final Amount fee;
  final Map<Address, Amount> destMap;
}
