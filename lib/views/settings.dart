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
  SettingsViewModel get viewModel => SettingsViewModel();

  Future<void> postUpdate(BuildContext context) async {
    viewModel.appConfig.save();
  }

  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [
        if (CupcakeConfig.instance.debug)
          BooleanConfigElement(
              title: "Debug",
              subtitleEnabled: "Debug options are enabled",
              subtitleDisabled: "Debug options are disabled",
              value: viewModel.appConfig.debug,
              onChange: (bool value) {
                viewModel.appConfig.debug = value;
                postUpdate(context);
              }),
        IntegerConfigElement(
            title: "Milliseconds for qr code",
            hint:
                "How many milliseconds should one QR code last before switching to next one",
            value: viewModel.appConfig.msForQrCode,
            onChange: (int value) {
              viewModel.appConfig.msForQrCode = value;
              postUpdate(context);
            }),
        BooleanConfigElement(
            title: "Biometric auth",
            subtitleEnabled: "Biometrics are enabled",
            subtitleDisabled:
                "In order to enable biometrics long press confirm button when entering pin",
            value: viewModel.appConfig.biometricEnabled,
            onChange: (bool value) async {
              if (value) return;
              viewModel.appConfig.biometricEnabled = false;
              final map = await secureStorage.readAll();
              for (var key in map.keys) {
                if (map[key]!.startsWith("UI.")) {
                  await secureStorage.delete(key: key);
                }
              }
              viewModel.appConfig.save();
              postUpdate(context);
            }),
        IntegerConfigElement(
          title: "Max fragment density",
          hint:
              "How many characters of data should fit within a single QR code",
          value: viewModel.appConfig.maxFragmentLength,
          onChange: (int value) {
            viewModel.appConfig.maxFragmentLength = value;
            postUpdate(context);
          },
        ),
        const VersionWidget(),
      ],
    );
  }
}
