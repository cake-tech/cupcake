import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/settings_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/settings/boolean_config_element.dart';
import 'package:cupcake/views/widgets/settings/integer_config_element.dart';
import 'package:cupcake/views/widgets/settings/version_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsView extends AbstractView {
  SettingsView({super.key});

  @override
  SettingsViewModel viewModel = SettingsViewModel();

  @override
  Widget? body(final BuildContext context) {
    return Column(
      children: [
        if (CupcakeConfig.instance.debug)
          BooleanConfigElement(
              title: "Debug",
              subtitleEnabled: "Debug options are enabled",
              subtitleDisabled: "Debug options are disabled",
              value: viewModel.configDebug,
              onChange: (final bool value) {
                viewModel.configDebug = value;
              }),
        IntegerConfigElement(
            title: "Milliseconds for qr code",
            hint: "How many milliseconds should one QR code last before switching to next one",
            value: viewModel.configMsForQrCode,
            onChange: (final int value) {
              viewModel.configMsForQrCode = value;
            }),
        BooleanConfigElement(
            title: "Biometric auth",
            subtitleEnabled: "Biometrics are enabled",
            subtitleDisabled:
                "In order to enable biometrics long press confirm button when entering pin",
            value: viewModel.configBiometricEnabled,
            onChange: (final bool value) async {
              if (value) return;
              viewModel.configBiometricEnabled = false;
              final map = await secureStorage.readAll();
              for (final key in map.keys) {
                if (map[key]!.startsWith("UI.")) {
                  await secureStorage.delete(key: key);
                }
              }
            }),
        if (viewModel.configDidFoundInsecureBiometric)
          BooleanConfigElement(
              title: "Insecure biometric auth",
              subtitleEnabled: "Insecure biometric authentication is enabled, it is not recommended"
                  " and could lead to loss of funds. Make sure that you understand the drawbacks,"
                  " and when in doubt - keep this setting disabled.",
              subtitleDisabled: "Click to enable insecure biometric authentication.",
              value: viewModel.configCanUseInsecureBiometric,
              onChange: (final bool value) async {
                viewModel.configCanUseInsecureBiometric = value;
              }),
        IntegerConfigElement(
          title: "Max fragment density",
          hint: "How many characters of data should fit within a single QR code",
          value: viewModel.configMaxFragmentLength,
          onChange: (final int value) async {
            viewModel.configMaxFragmentLength = value;
          },
        ),
        const VersionWidget(),
      ],
    );
  }
}
