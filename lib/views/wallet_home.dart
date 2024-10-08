import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/wallet_home_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/barcode_scanner.dart';
import 'package:cup_cake/views/receive.dart';
import 'package:cup_cake/views/widgets/cake_card.dart';
import 'package:cup_cake/views/widgets/drawer_element.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cup_cake/gen/assets.gen.dart';

// ignore: must_be_immutable
class WalletHome extends AbstractView {
  WalletHome({super.key, required CoinWallet coinWallet})
      : viewModel = WalletHomeViewModel(wallet: coinWallet);

  static Future<void> pushStatic(BuildContext context, CoinWallet coin) async {
    await Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return WalletHome(coinWallet: coin);
        },
      ),
    );
  }

  @override
  final WalletHomeViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  // TODO: implement drawer
  Drawer? get drawer => Drawer(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 16),
                Assets.coins.xmr.svg(width: 72),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.wallet.walletName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(L.primary_account_label),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            DrawerElements(
              coinWallet: viewModel.wallet,
            ),
          ],
        ),
      );

  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 56),
        CakeCard(
            child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(L.balance),
                Text(
                  viewModel.balance,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 32),
                ),
              ],
            ),
            const Spacer(),
            SizedBox.square(
              dimension: 42,
              child: viewModel.coin.strings.svg,
            ),
          ],
        )),
        CakeCard(
          firmPadding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Receive.pushStatic(context, viewModel.wallet),
                    icon:
                        const Icon(Icons.inbox, size: 35, color: Colors.white),
                    label: Text(
                      L.receive,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        BarcodeScanner.pushStatic(context, viewModel.wallet),
                    icon: const Icon(
                      Icons.qr_code_2,
                      size: 35,
                      color: Colors.white,
                    ),
                    label: Text(
                      L.scan,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
