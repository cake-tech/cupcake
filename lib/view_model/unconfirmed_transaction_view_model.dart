import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/view_model/abstract.dart';

part 'unconfirmed_transaction_view_model.g.dart';

@GenerateRebuild()
class UnconfirmedTransactionViewModel extends ViewModel {
  UnconfirmedTransactionViewModel(
      {required this.wallet,
      required this.fee,
      required this.destMap,
      required final FutureOr<void> Function() confirmCallback,
      required final FutureOr<void> Function() cancelCallback})
      : _confirmCallback = confirmCallback,
        _cancelCallback = cancelCallback;

  final CoinWallet wallet;

  @override
  late String screenName = wallet.coin.strings.nameFull;

  final FutureOr<void> Function() _confirmCallback;
  final FutureOr<void> Function() _cancelCallback;

  @ThrowOnUI(message: "Failed to confirm")
  Future<void> $confirmCallback() async => await _confirmCallback();
  @ThrowOnUI(message: "Failed to cancel")
  Future<void> $cancelCallback() async => await _cancelCallback();

  final Amount fee;
  final Map<Address, Amount> destMap;
}
