import 'package:cupcake/l10n/app_localizations.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/material.dart';

class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (final context, final state, final child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }
        final L = AppLocalizations.of(context)!;

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              iconSize: 32.0,
              icon: Icon(Icons.flash_auto, semanticLabel: L.toggle_flashlight),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              iconSize: 32.0,
              icon: Icon(Icons.flash_off, semanticLabel: L.toggle_flashlight),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              iconSize: 32.0,
              icon: Icon(Icons.flash_on, semanticLabel: L.toggle_flashlight),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.grey,
            );
        }
      },
    );
  }
}
