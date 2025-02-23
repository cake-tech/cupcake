import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/material.dart';

class UnconfirmedTransactionView extends AbstractView {
  UnconfirmedTransactionView({
    super.key,
    required CoinWallet wallet,
    required Amount fee,
    required Map<Address, Amount> destMap,
    required FutureOr<void> Function(BuildContext) confirmCallback,
    required FutureOr<void> Function(BuildContext) cancelCallback,
  }) : viewModel = UnconfirmedTransactionViewModel(
          wallet: wallet,
          fee: fee,
          destMap: destMap,
          confirmCallback: confirmCallback,
          cancelCallback: cancelCallback,
        );

  @override
  final UnconfirmedTransactionViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    final keys = viewModel.destMap.keys.toList();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (BuildContext context, int index) {
        final key = keys[index];
        final value = viewModel.destMap[key]!;
        return ListTile(
          subtitle: Text(key.address),
          title: Text(value.toString()),
        );
      },
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          label: L.cancel,
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            label: L.confirm),
      ],
      onTap: (int index) async {
        if (index == 0) {
          await callThrowable(context,
              () async => await viewModel.cancelCallback(context), L.canceling);
          if (!context.mounted) return;
          Navigator.of(context).pop();
        } else {
          await callThrowable(
              context,
              () async => await viewModel.confirmCallback(context),
              L.confirming);
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
    );
  }
}
