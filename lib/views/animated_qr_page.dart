import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/urqr_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:cupcake/views/widgets/urqr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AnimatedURPage extends AbstractView {
  AnimatedURPage({
    super.key,
    required final Map<String, List<String>> urqrList,
    required final CoinWallet currentWallet,
  }) : viewModel = URQRViewModel(
          urqrList: urqrList,
          currentWallet: currentWallet,
        );

  @override
  final URQRViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  Widget body(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 32, right: 32),
          child: Observer(
            builder: (final context) {
              return URQR(
                frames: viewModel.urqr,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, top: 64),
          child: Text(
            L.animated_qr_note,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: T.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  List<Widget> _extraButtons() {
    final List<Widget> toRet = [];
    for (final key in viewModel.alternativeCodes) {
      toRet.add(_urqrSwitchButton(key, viewModel.urqrList[key]!));
    }
    return toRet;
  }

  Widget _urqrSwitchButton(final String key, final List<String> value) {
    return LongSecondaryButton(
      T,
      onPressed: () {
        viewModel.urqr = value;
      },
      text: key,
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Observer(
      builder: (final context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._extraButtons(),
            LongPrimaryButton(
              icon: Icons.home,
              text: "Home",
              onPressed: () async {
                await WalletHome(coinWallet: viewModel.currentWallet).push(context);
              },
            ),
          ],
        );
      },
    );
  }
}
