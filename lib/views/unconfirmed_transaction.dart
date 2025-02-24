import 'dart:async';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/material.dart';

class UnconfirmedTransactionView extends AbstractView {
  UnconfirmedTransactionView({
    super.key,
    required final CoinWallet wallet,
    required final Amount fee,
    required final Map<Address, Amount> destMap,
    required final FutureOr<void> Function() confirmCallback,
    required final FutureOr<void> Function() cancelCallback,
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
  Widget? body(final BuildContext context) {
    final keys = viewModel.destMap.keys.toList();
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (final BuildContext context, final int index) {
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
  Widget? bottomNavigationBar(final BuildContext context) {
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
      onTap: (final int index) async {
        if (index == 0) {
          viewModel.cancelCallback();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        } else {
          await viewModel.confirmCallback();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
    );
  }
}
