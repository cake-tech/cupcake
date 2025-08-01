import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/home_screen_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends AbstractView {
  HomeScreen({
    super.key,
    required final bool openLastWallet,
    final String? lastOpenedWallet,
  }) : viewModel = HomeScreenViewModel(
          openLastWallet: openLastWallet,
          lastOpenedWallet: lastOpenedWallet,
        );
  @override
  AppBar? get appBar => AppBar(
        title: Assets.icons.cupcakeNavbar.svg(),
        automaticallyImplyLeading: canPop,
        actions: [
          IconButton(
            onPressed: viewModel.toggleSort,
            icon: const Icon(Icons.sort),
          ),
        ],
      );

  @override
  final HomeScreenViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return FutureBuilder(
      future: viewModel.showLandingInfo,
      builder: (final BuildContext context, final AsyncSnapshot<bool> value) {
        if (!value.hasData) return Container();
        if (value.data!) {
          return Center(
            child: Text(
              L.home_no_wallets,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return Observer(
          builder: (final context) {
            return FutureBuilder(
              future: viewModel.wallets(viewModel.varWalletSort),
              builder: (
                final BuildContext context,
                final AsyncSnapshot<List<CoinWalletInfo>> wallets,
              ) {
                return walletsBody(context, wallets);
              },
            );
          },
        );
      },
    );
  }

  Widget walletsBody(
    final BuildContext context,
    final AsyncSnapshot<List<CoinWalletInfo>> wallets,
  ) {
    if (!wallets.hasData) return Container();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.separated(
        itemCount: wallets.data!.length,
        separatorBuilder: (final context, final index) => const SizedBox(height: 16),
        itemBuilder: (final BuildContext context, final int index) {
          return singleWalletWidget(context, wallets.data![index]);
        },
      ),
    );
  }

  Widget singleWalletWidget(
    final BuildContext context,
    final CoinWalletInfo wallet,
  ) {
    return GestureDetector(
      onTap: () => wallet.openUI(context),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff2B3A67),
              Color(0xff1C2A4F),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 32,
              child: wallet.coin.strings.svg.svg(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                p.basename(wallet.walletName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => viewModel.renameWallet(wallet),
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: T.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(512),
                ),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: T.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LongSecondaryButton(
          T,
          onPressed: () {
            CreateWallet(
              viewModel: CreateWalletViewModel(
                createMethod: CreateMethod.restore,
                needsPasswordConfirm: false,
              ),
            ).push(context);
          },
          text: L.restore_wallet,
        ),
        LongPrimaryButton(
          onPressed: () {
            CreateWallet(
              viewModel: CreateWalletViewModel(
                createMethod: CreateMethod.create,
                needsPasswordConfirm: false,
              ),
            ).push(context);
          },
          text: L.create_new_wallet,
        ),
      ],
    );
  }

  @override
  Future<void> initState(final BuildContext context) {
    return viewModel.loadInitialState(context);
  }
}
