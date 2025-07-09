import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/view_model/wallet_home_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/barcode_scanner.dart';
import 'package:cupcake/views/connect_wallet.dart';
import 'package:cupcake/views/home_screen.dart';
import 'package:cupcake/views/receive.dart';
import 'package:cupcake/views/security_backup.dart';
import 'package:cupcake/views/settings.dart';
import 'package:cupcake/views/widgets/settings/about_widget.dart';
import 'package:flutter/material.dart';

class WalletHome extends AbstractView {
  WalletHome({
    super.key,
    required final CoinWallet coinWallet,
  }) : viewModel = WalletHomeViewModel(
          wallet: coinWallet,
        );

  @override
  final WalletHomeViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  bool get automaticallyImplyLeading => false;

  @override
  bool get hasBackground => true;

  @override
  Widget? body(final BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _appBar,
            const SizedBox(height: 40),
            Spacer(flex: 4),
            _walletSelector(context),
            const Spacer(flex: 3),
            _bottomActions(context),
            Spacer(flex: 1),
            const SizedBox(height: 40),
          ],
        ),
        // Corner dots
        _buildCornerDots(context),
      ],
    );
  }

  Widget _walletSelector(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42),
      child: GestureDetector(
        onTap: () => HomeScreen(openLastWallet: false).push(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF000D2B),
                Color(0xFF000D2B).withAlpha(230),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 32,
                child: viewModel.coin.strings.svg,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  viewModel.wallet.walletName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  AppBar? get appBar => null;

  AppBar get _appBar => AppBar(
        automaticallyImplyLeading: false,
        title: Assets.icons.cupcakeNavbar.svg(),
      );

  Widget _bottomActions(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            context,
            svgAsset: Assets.icons.menuDeposit.svg(
              width: 64,
              height: 64,
            ),
            onPressed: () => Receive(coinWallet: viewModel.wallet).push(context),
          ),
          _actionButton(
            context,
            svgAsset: Assets.icons.menuQr.svg(
              width: 64,
              height: 64,
            ),
            onPressed: () => BarcodeScanner(wallet: viewModel.wallet).push(context),
          ),
          _actionButton(
            context,
            svgAsset: Assets.icons.menuMenu.svg(
              width: 64,
              height: 64,
            ),
            onPressed: () => _showBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    final BuildContext context, {
    required final Widget svgAsset,
    required final VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: svgAsset,
    );
  }

  void _showBottomSheet(final BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (final context) => _buildBottomSheet(context),
    );
  }

  Widget _buildBottomSheet(final BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF273765),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(76),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _buildBottomSheetGradientCard(
                  context,
                  icon: Assets.icons.nav.cakeDark.svg(width: 24, height: 24),
                  title: "Sync to Cake Wallet",
                  onTap: () {
                    BarcodeScanner(wallet: viewModel.wallet).push(context);
                  },
                ),
                const SizedBox(height: 8),
                _buildBottomSheetCard(
                  context,
                  icon: Assets.icons.nav.cakeLight.svg(width: 24, height: 24),
                  title: "Connect to Cake Wallet",
                  backgroundColor: const Color(0xFF1B284A),
                  textColor: Colors.white,
                  onTap: () => ConnectWallet(wallet: viewModel.wallet).push(context),
                ),
                const SizedBox(height: 8),
                _buildBottomSheetCard(
                  context,
                  icon: Assets.icons.nav.wallets.svg(width: 24, height: 24),
                  title: "Wallets",
                  backgroundColor: const Color(0xFF1B284A),
                  textColor: Colors.white,
                  onTap: () => HomeScreen(openLastWallet: false).push(context),
                ),
                const SizedBox(height: 8),
                _buildBottomSheetCard(
                  context,
                  icon: Assets.icons.nav.seedAndKeys.svg(width: 24, height: 24),
                  title: "Seed and keys",
                  backgroundColor: const Color(0xFF1B284A),
                  textColor: Colors.white,
                  onTap: () => SecurityBackup(coinWallet: viewModel.wallet).push(context),
                ),
                const SizedBox(height: 8),
                _buildBottomSheetCard(
                  context,
                  icon: Assets.icons.nav.otherSettings.svg(width: 24, height: 24),
                  title: "Other settings",
                  backgroundColor: const Color(0xFF1B284A),
                  textColor: Colors.white,
                  onTap: () => SettingsView(wallet: viewModel.wallet).push(context),
                ),
                const SizedBox(height: 8),
                AboutWidget(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCornerDots(final BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: _buildCornerDot(),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _buildCornerDot(),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildCornerDot(),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildCornerDot(),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerDot() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(40),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildBottomSheetGradientCard(
    final BuildContext context, {
    required final Widget icon,
    required final String title,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF2A92FA),
              Color(0xFF61C5FF),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            icon,
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetCard(
    final BuildContext context, {
    required final Widget icon,
    required final String title,
    required final Color backgroundColor,
    required final Color textColor,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            icon,
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
