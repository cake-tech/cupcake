import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/settings_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/open_wallet.dart';
import 'package:cupcake/views/ui_playground.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/settings/boolean_config_element.dart';
import 'package:cupcake/views/widgets/settings/integer_config_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SettingsView extends AbstractView {
  SettingsView({super.key, required final CoinWallet wallet})
      : viewModel = SettingsViewModel(wallet: wallet);

  @override
  final SettingsViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return Column(
      children: [
        if (viewModel.debug)
          Observer(
            builder: (final context) {
              return BooleanConfigElement(
                title: L.settings_debug_title,
                subtitleEnabled: L.settings_debug_enabled,
                subtitleDisabled: L.settings_debug_disabled,
                value: viewModel.debug,
                onChange: (final bool value) {
                  viewModel.debug = value;
                  viewModel.save();
                },
              );
            },
          ),
        if (viewModel.debug)
          Observer(
            builder: (final context) {
              return IntegerConfigElement(
                title: L.settings_msForQrCode_title,
                hint: L.settings_msForQrCode_hint,
                value: viewModel.msForQrCode,
                onChange: (final int value) {
                  viewModel.msForQrCode = value;
                  viewModel.save();
                },
              );
            },
          ),
        Observer(
          builder: (final context) {
            return BooleanConfigElement(
              title: L.settings_biometricsEnabled_title,
              subtitleEnabled: null,
              subtitleDisabled: null,
              value: viewModel.biometricEnabled,
              onChange: (final bool value) async {
                if (value) {
                  await OpenWallet(
                    coinWalletInfo: viewModel.wallet.walletInfo,
                    enableBiometric: true,
                  ).push(context);
                }
                viewModel.biometricEnabled = false;
                final map = await secureStorage.readAll();
                for (final key in map.keys) {
                  if (map[key]!.startsWith("UI.")) {
                    await secureStorage.delete(key: key);
                  }
                }
                viewModel.save();
              },
            );
          },
        ),
        if (viewModel.debug || viewModel.canUseInsecureBiometric)
          Observer(
            builder: (final context) {
              return BooleanConfigElement(
                title: L.settings_canUseInsecureBiometric_title,
                subtitleEnabled: L.settings_canUseInsecureBiometric_enabled,
                subtitleDisabled: L.settings_canUseInsecureBiometric_disabled,
                value: viewModel.canUseInsecureBiometric,
                onChange: (final bool value) {
                  viewModel.canUseInsecureBiometric = value;
                  viewModel.save();
                },
              );
            },
          ),
        if (viewModel.debug)
          Observer(
            builder: (final context) {
              return IntegerConfigElement(
                title: L.settings_maxFragmentLength_title,
                hint: L.settings_maxFragmentLength_hint,
                value: viewModel.maxFragmentLength,
                onChange: (final int value) {
                  viewModel.maxFragmentLength = value;
                  viewModel.save();
                },
              );
            },
          ),
        if (viewModel.debug)
          LongPrimaryButton(
            onPressed: () => UIPlayground(wallet: viewModel.wallet).push(context),
            text: "UI Playground",
          ),
        if (viewModel.debug)
          ...List.generate(
            viewModel.wallet.coin.debugOptions.length,
            (final int i) {
              final key = viewModel.wallet.coin.debugOptions.keys.toList()[i];
              return ElevatedButton(
                onPressed: () async {
                  await viewModel.wallet.coin.debugOptions[key]?.call(context, viewModel.wallet);
                },
                child: Text(key),
              );
            },
          ),
      ],
    );
  }
}
