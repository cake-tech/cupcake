import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/monero/coin.dart';
import 'package:cup_cake/view_model/barcode_scanner_view_model.dart';
import 'package:cup_cake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:cup_cake/view_model/urqr_view_model.dart';
import 'package:cup_cake/views/unconfirmed_transaction.dart';
import 'package:cup_cake/views/urqr.dart';
import 'package:flutter/cupertino.dart';
import 'package:monero/monero.dart' as monero;

class MoneroWallet implements CoinWallet {
  MoneroWallet(this.wptr);
  monero.wallet wptr;

  void save() {
    monero.Wallet_store(wptr);
  }

  @override
  Coin coin = Monero();

  @override
  bool get hasAccountSupport => true;
  @override
  bool get hasAddressesSupport => true;

  int _accountIndex = 0;
  @override
  int getAccountsCount() => monero.Wallet_numSubaddressAccounts(wptr);
  @override
  void setAccount(int accountIndex) {
    if (_accountIndex < getAccountsCount()) {
      throw Exception("Given index is larger than current account count");
    }
    _accountIndex = accountIndex;
    save();
  }

  @override
  int getAccountId() => _accountIndex;

  @override
  int get addressIndex =>
      monero.Wallet_numSubaddresses(wptr, accountIndex: getAccountId());

  @override
  String get getAccountLabel => monero.Wallet_getSubaddressLabel(wptr,
      accountIndex: _accountIndex, addressIndex: 0);

  @override
  String get getCurrentAddress => monero.Wallet_address(wptr,
      accountIndex: getAccountId(), addressIndex: addressIndex);

  @override
  int getBalance() => monero.Wallet_balance(wptr, accountIndex: getAccountId());

  @override
  String getBalanceString() => (getBalance() / 1e12).toStringAsFixed(8);

  @override
  Future<void> handleUR(BuildContext context, URQRData ur) async {
    print("handling: ${ur.tag}.");
    switch (ur.tag) {
      case "xmr-keyimage" || "xmr-txsigned":
        throw Exception("Unable to handle ${ur.tag}. This is a offline wallet");
      case "xmr-output":
        monero.Wallet_importOutputsUR(wptr, ur.inputs.join("\n"));
        var status = monero.Wallet_status(wptr);
        if (status != 0) {
          final error = monero.Wallet_errorString(wptr);
          throw CoinException(error);
        }
        final allImages = monero.Wallet_exportKeyImagesUR(wptr,
                max_fragment_length: 130, all: true)
            .split("\n");
        final someImages = monero.Wallet_exportKeyImagesUR(wptr,
                max_fragment_length: 130, all: false)
            .split("\n");
        await AnimatedURPage.staticPush(
          context,
          URQRViewModel(
            urqrList: {
              "Partial Key Images": someImages,
              "All Key Images": allImages,
            },
          ),
        );
        save();
      case "xmr-txunsigned":
        print("handling tx-unsignex");
        final txptr =
            monero.Wallet_loadUnsignedTxUR(wptr, input: ur.inputs.join("\n"));
        var status = monero.Wallet_status(wptr);
        if (status != 0) {
          final error = monero.Wallet_errorString(wptr);
          throw CoinException(error);
        }
        status = monero.UnsignedTransaction_status(txptr);
        if (status != 0) {
          final error = monero.UnsignedTransaction_errorString(txptr);
          throw CoinException(error);
        }
        Map<Address, MoneroAmount> destMap = {};
        final amts = monero.UnsignedTransaction_amount(txptr)
            .split(";")
            .map((e) => int.parse(e))
            .toList();
        final addrs =
            monero.UnsignedTransaction_recipientAddress(txptr).split(";");
        if (amts.length != addrs.length) {
          throw CoinException("Amount and address length is not equal.");
        }
        for (int i = 0; i < amts.length; i++) {
          destMap[Address(addrs[i])] = MoneroAmount(amts[i]);
        }
        final fee =
            MoneroAmount(int.parse(monero.UnsignedTransaction_fee(txptr)));
        await UnconfirmedTransactionView.staticPush(
          context,
          UnconfirmedTransactionViewModel(
            wallet: this,
            destMap: destMap,
            fee: fee,
            confirmCallback: (BuildContext context) async {
              final signedTx =
                  monero.UnsignedTransaction_signUR(txptr, 130).split("\n");
              var status = monero.Wallet_status(wptr);
              if (status != 0) {
                final error = monero.Wallet_errorString(wptr);
                throw CoinException(error);
              }
              status = monero.UnsignedTransaction_status(txptr);
              if (status != 0) {
                final error = monero.UnsignedTransaction_errorString(txptr);
                throw CoinException(error);
              }
              await AnimatedURPage.staticPush(
                  context, URQRViewModel(urqrList: {"signedTx": signedTx}));
            },
            cancelCallback: (BuildContext context) => {},
          ),
        );
        save();
      default:
        throw UnimplementedError("Unable to handle ${ur.tag}.");
    }
  }
}

class MoneroAmount implements Amount {
  MoneroAmount(this.amount);
  @override
  final int amount;

  @override
  String toString() => monero.Wallet_displayAmount(amount);
}
