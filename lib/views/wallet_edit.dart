import 'dart:ui';

import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/view_model/wallet_edit_view_model.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/material.dart';

class WalletEdit {
  WalletEdit({
    required final CoinWalletInfo walletInfo,
  }) : viewModel = WalletEditViewModel(
          walletInfo: walletInfo,
        );

  AppLocalizations get L => viewModel.L;
  ThemeData get T => viewModel.T;
  Future<dynamic> push(final BuildContext context) {
    viewModel.register(context);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (final context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: T.colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildBottomSheet(context),
        ),
      ),
    );
  }

  WalletEditViewModel viewModel;

  Widget _buildBottomSheet(final BuildContext context) {
    viewModel.register(context);
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.1,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Color(0xff1B284A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.center,
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
              ],
            ),
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: IconButton(
                      onPressed: () => viewModel.deleteWallet(),
                      icon: Assets.icons.delete.svg(
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    viewModel.walletInfo.coin.strings.svg.svg(),
                    const SizedBox(width: 8),
                    Text(
                      L.edit_wallet,
                      style: TextStyle(
                        color: T.colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          FormBuilder(
            showExtra: true,
            viewModel: viewModel.formBuilderViewModel,
          ),
          SizedBox(
            height: 280,
          ),
          bottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget bottomNavigationBar(final BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Spacer(),
          Expanded(
            flex: 2,
            child: LongSecondaryButton(
              T,
              icon: null,
              onPressed: () => Navigator.of(context).pop(),
              text: L.cancel,
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 2,
            child: LongPrimaryButton(
              icon: null,
              onPressed: () => viewModel.renameWallet(),
              text: L.rename,
              padding: EdgeInsets.zero,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
