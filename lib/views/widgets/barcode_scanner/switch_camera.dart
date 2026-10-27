import 'package:cupcake/l10n/app_localizations.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/material.dart';

class SwitchCameraButton extends StatelessWidget {
  const SwitchCameraButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(final BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (final context, final state, final child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final int? availableCameras = state.availableCameras;

        if (availableCameras != null && availableCameras < 2) {
          return const SizedBox.shrink();
        }

        final Widget icon;
        final L = AppLocalizations.of(context)!;

        switch (state.cameraDirection) {
          case CameraFacing.front:
            icon = Icon(Icons.camera_front, semanticLabel: L.switch_camera);
          case CameraFacing.back:
            icon = Icon(Icons.camera_rear, semanticLabel: L.switch_camera);
        }

        return IconButton(
          iconSize: 32.0,
          icon: icon,
          onPressed: () async {
            await controller.switchCamera();
          },
        );
      },
    );
  }
}
