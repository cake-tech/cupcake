import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/view_model/settings_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/settings/boolean_config_element.dart';
import 'package:cupcake/views/widgets/settings/integer_config_element.dart';
import 'package:cupcake/views/widgets/settings/version_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SettingsView extends AbstractView {
  SettingsView({super.key});

  @override
  SettingsViewModel viewModel = SettingsViewModel();

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
              subtitleEnabled: L.settings_biometricsEnabled_enabled,
              subtitleDisabled: L.settings_biometricsEnabled_disabled,
              value: viewModel.biometricEnabled,
              onChange: (final bool value) async {
                if (value) return;
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
        const VersionWidget(),
      ],
    );
  }
}
