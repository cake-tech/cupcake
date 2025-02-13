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
            title: L.settings_debug_title,
            subtitleEnabled: L.settings_debug_enabled,
            subtitleDisabled: L.settings_debug_disabled,
            value: viewModel.configDebug,
            onChange: (final bool value) {
              viewModel.configDebug = value;
            },
          ),
        IntegerConfigElement(
          title: L.settings_msForQrCode_title,
          hint: L.settings_msForQrCode_hint,
          value: viewModel.configMsForQrCode,
          onChange: (final int value) {
            viewModel.configMsForQrCode = value;
          },
        ),
        BooleanConfigElement(
          title: L.settings_biometricsEnabled_title,
          subtitleEnabled: L.settings_biometricsEnabled_enabled,
          subtitleDisabled: L.settings_biometricsEnabled_disabled,
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
          },
        ),
        if (viewModel.configDidFoundInsecureBiometric)
          BooleanConfigElement(
            title: L.settings_canUseInsecureBiometric_title,
            subtitleEnabled: L.settings_canUseInsecureBiometric_enabled,
            subtitleDisabled: L.settings_canUseInsecureBiometric_disabled,
            value: viewModel.configCanUseInsecureBiometric,
            onChange: (final bool value) {
              viewModel.configCanUseInsecureBiometric = value;
            },
          ),
        IntegerConfigElement(
          title: L.settings_maxFragmentLength_title,
          hint: L.settings_maxFragmentLength_hint,
          value: viewModel.configMaxFragmentLength,
          onChange: (final int value) {
            viewModel.configMaxFragmentLength = value;
          },
        ),
        const VersionWidget(),
      ],
    );
  }
}
