import 'dart:math';

import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/alerts/basic.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/ui_playground_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/animated_qr_page.dart';
import 'package:cupcake/views/barcode_scanner.dart';
import 'package:cupcake/views/connect_wallet.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:cupcake/views/receive.dart';
import 'package:cupcake/views/security_backup.dart';
import 'package:cupcake/views/settings.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:cupcake/views/verify_seed_page.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';

class UIPlayground extends AbstractView {
  UIPlayground({
    super.key,
    required final CoinWallet wallet,
  }) : viewModel = UIPlaygroundViewModel(wallet: wallet);

  @override
  final UIPlaygroundViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  Widget body(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: screens(context)
            .entries
            .map(
              (final entry) => LongPrimaryButton(
                text: entry.key,
                onPressed: entry.value,
              ),
            )
            .toList(),
      ),
    );
  }

  late final Map<String, List<String>> _dummyURQRs = {
    "urqr 1": _genList(CupcakeConfig.instance.maxFragmentLength, 10),
    "urqr 2": _genList(CupcakeConfig.instance.maxFragmentLength, 10),
  };

  List<String> _genList(final int length, final int count) {
    return List.generate(
      count,
      (final int i) => _genString(length),
    );
  }

  String _genString(final int length) {
    return List.generate(
      length,
      (final int i) => "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          .split('')
          .toList()[(DateTime.now().microsecondsSinceEpoch + i * 13) % 62],
    ).join();
  }

  final random = Random();

  List<String> _genSeedWords(final int count) {
    return List.generate(
      count,
      (final int i) {
        final length = 3 + random.nextInt(10);
        return "(${i + 1})-${_genString(length)}";
      },
    );
  }

  Map<String, VoidCallback> screens(final BuildContext context) {
    return {
      "AnimatedURPage (single)": () => AnimatedURPage(
            urqrList: {_dummyURQRs.keys.first: _dummyURQRs[_dummyURQRs.keys.first]!},
            currentWallet: viewModel.wallet,
          ).push(context),
      "AnimatedURPage (multi)": () =>
          AnimatedURPage(urqrList: _dummyURQRs, currentWallet: viewModel.wallet).push(context),
      "BarcodeScanner": () => BarcodeScanner(wallet: viewModel.wallet).push(context),
      "ConnectWallet(canSkip: true)": () => ConnectWallet(
            wallet: viewModel.wallet,
            canSkip: true,
          ).push(context),
      "ConnectWallet(canSkip: false)": () => ConnectWallet(
            wallet: viewModel.wallet,
            canSkip: false,
          ).push(context),
      "CreateWallet(.create, passwordConfirm: false)": () => CreateWallet(
            viewModel: CreateWalletViewModel(
              createMethod: CreateMethod.create,
              needsPasswordConfirm: false,
            ),
          ).push(context),
      "CreateWallet(.create, passwordConfirm: true)": () => CreateWallet(
            viewModel: CreateWalletViewModel(
              createMethod: CreateMethod.create,
              needsPasswordConfirm: true,
            ),
          ).push(context),
      "CreateWallet(.restore, passwordConfirm: false)": () => CreateWallet(
            viewModel: CreateWalletViewModel(
              createMethod: CreateMethod.restore,
              needsPasswordConfirm: false,
            ),
          ).push(context),
      "CreateWallet(.restore, passwordConfirm: true)": () => CreateWallet(
            viewModel: CreateWalletViewModel(
              createMethod: CreateMethod.restore,
              needsPasswordConfirm: true,
            ),
          ).push(context),
      "CreateWallet(null, passwordConfirm: false)": () => CreateWallet(
            viewModel: CreateWalletViewModel(createMethod: null, needsPasswordConfirm: false),
          ).push(context),
      "CreateWallet(null, passwordConfirm: true)": () => CreateWallet(
            viewModel: CreateWalletViewModel(createMethod: null, needsPasswordConfirm: true),
          ).push(context),
      "Home(openLastWallet: false)": () => HomeScreen(openLastWallet: false).push(context),
      "Home(openLastWallet: true)": () => HomeScreen(openLastWallet: true).push(context),
      "InitialSetupScreen": () => InitialSetupScreen().push(context),
      "NewWalletInfoScreen(preShowSeedPage)": () => NewWalletInfoScreen(
            pages: [
              NewWalletInfoPage.preShowSeedPage(L, T),
            ],
          ).push(context),
      "NewWalletInfoScreen(writeDownNotice)": () => NewWalletInfoScreen(
            pages: [
              NewWalletInfoPage.writeDownNotice(
                L,
                T,
                text: "test",
                title: "test",
              ),
            ],
          ).push(context),
      "NewWalletInfoScreen(seedWrittenDown)": () => NewWalletInfoScreen(
            pages: [
              NewWalletInfoPage.seedWrittenDown(
                L,
                T,
                wallet: viewModel.wallet,
                nextCallback: () async => _alert(context, "nextCallback"),
              ),
            ],
          ).push(context),
      "Receive": () => Receive(coinWallet: viewModel.wallet).push(context),
      "SecurityBackup": () => SecurityBackup(coinWallet: viewModel.wallet).push(context),
      "Settings": () => SettingsView(wallet: viewModel.wallet).push(context),
      "UIPlayground": () => UIPlayground(wallet: viewModel.wallet).push(context),
      "UnconfirmedTransaction(single)": () => UnconfirmedTransactionView(
            wallet: viewModel.wallet,
            fee: Amount(0),
            destMap: {Address("test"): Amount(0)},
            confirmCallback: (final BuildContext context) => {_alert(context, "confirmCallback")},
            cancelCallback: () => _alert(context, "cancelCallback"),
          ).pushReplacement(context),
      "UnconfirmedTransaction(multi)": () => UnconfirmedTransactionView(
            wallet: viewModel.wallet,
            fee: Amount(0),
            destMap: {Address("test"): Amount(0), Address("test2"): Amount(1)},
            confirmCallback: (final BuildContext context) => {_alert(context, "confirmCallback")},
            cancelCallback: () => _alert(context, "cancelCallback"),
          ).pushReplacement(context),
      "VerifySeed(seedWords: 12, wordList: (4, 1000))": () =>
          VerifySeedPage(seedWords: _genSeedWords(12), wordList: _genList(4, 1000)).push(context),
      "VerifySeed(seedWords: 16, wordList: (4, 1000))": () =>
          VerifySeedPage(seedWords: _genSeedWords(16), wordList: _genList(4, 1000)).push(context),
      "VerifySeed(seedWords: 25, wordList: (4, 1000))": () =>
          VerifySeedPage(seedWords: _genSeedWords(25), wordList: _genList(4, 1000)).push(context),
      "VerifySeed(seedWords: 25, wordList: (4, 1))": () =>
          VerifySeedPage(seedWords: _genSeedWords(25), wordList: _genList(4, 1)).push(context),
      "WalletHome": () => WalletHome(coinWallet: viewModel.wallet).push(context),
    };
  }

  void _alert(final BuildContext context, final String message) {
    Navigator.of(context).pop();
    showAlert(context: context, title: "callback", body: [message]);
  }
}
