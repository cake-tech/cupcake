import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/wallet_home_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/barcode_scanner.dart';
import 'package:cupcake/views/receive.dart';
import 'package:cupcake/views/widgets/cake_card.dart';
import 'package:cupcake/views/widgets/drawer_elements.dart';
import 'package:flutter/material.dart';
import 'package:cupcake/gen/assets.gen.dart';

class WalletHome extends AbstractView {
  WalletHome({super.key, required final CoinWallet coinWallet})
      : viewModel = WalletHomeViewModel(wallet: coinWallet);

  @override
  final WalletHomeViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  Drawer? get drawer => Drawer(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(top: 50, bottom: 24)),
                    const SizedBox(width: 16),
                    Assets.coins.xmr.svg(width: 50),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.wallet.walletName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(L.primary_account_label),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                DrawerElements(
                  coinWallet: viewModel.wallet,
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget? body(final BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _currencyInfo(context),
        _actions(context),
      ],
    );
  }

  CakeCard _actions(final BuildContext context) {
    return CakeCard(
      firmPadding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _actionReceive(context),
          const SizedBox(width: 8),
          _actionScan(context),
        ],
      ),
    );
  }

  Expanded _actionScan(final BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () =>
              BarcodeScanner(wallet: viewModel.wallet).push(context),
          icon: const Icon(
            Icons.qr_code_rounded,
            size: 35,
            color: Colors.white,
          ),
          label: Text(
            L.scan,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Expanded _actionReceive(final BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 64,
        child: ElevatedButton.icon(
          onPressed: () => Receive(coinWallet: viewModel.wallet).push(context),
          icon: const Icon(Icons.call_received, size: 35, color: Colors.white),
          label: Text(
            L.receive,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  CakeCard _currencyInfo(final BuildContext context) {
    return CakeCard(
        child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.balance,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
            Text(
              viewModel.balance,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const Spacer(),
        SizedBox.square(
          dimension: 42,
          child: viewModel.coin.strings.svg,
        ),
      ],
    ));
  }
}
