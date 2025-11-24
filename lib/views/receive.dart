import 'dart:ui';

import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/formatter_address.dart';
import 'package:cupcake/view_model/receive_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/guarded_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receive extends AbstractView {
  Receive({
    super.key,
    required final CoinWallet coinWallet,
  }) : viewModel = ReceiveViewModel(
          coinWallet,
        );

  @override
  final ReceiveViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) => _body(context) ?? const SizedBox.shrink(),
    );
  }

  Widget? _body(final BuildContext context) {
    if (viewModel.isFullPage) {
      return GuardedGestureDetector(
        onTap: _toggleFullPage,
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white,
              ),
              child: GuardedGestureDetector(
                onTap: _toggleFullPage,
                child: QrImageView(
                  data: "${viewModel.uriScheme}:${viewModel.address}",
                  dataModuleStyle: QrDataModuleStyle(
                    color: Colors.black,
                    dataModuleShape: QrDataModuleShape.square,
                  ),
                  embeddedImage: AssetImage(Assets.icons.cupcakeQr.path),
                  embeddedImageEmitsError: true,
                  eyeStyle: QrEyeStyle(
                    color: Colors.black,
                    eyeShape: QrEyeShape.square,
                  ),
                ),
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 48, right: 48, bottom: 32),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white,
              ),
              child: GuardedGestureDetector(
                onTap: _toggleFullPage,
                child: QrImageView(
                  data: "${viewModel.uriScheme}:${viewModel.address}",
                  dataModuleStyle: QrDataModuleStyle(
                    color: Colors.black,
                    dataModuleShape: QrDataModuleShape.square,
                  ),
                  embeddedImage: AssetImage(Assets.icons.cupcakeQr.path),
                  embeddedImageEmitsError: true,
                  eyeStyle: QrEyeStyle(
                    color: Colors.black,
                    eyeShape: QrEyeShape.square,
                  ),
                ),
              ),
            ),
          ),
          _addressPicker(context),
          Spacer(flex: 2),
          _addressWidget(),
          Spacer(
            flex: 8,
          ),
        ],
      ),
    );
  }

  Widget _addressPicker(final BuildContext context) {
    if (viewModel.wallet.address.length <= 1) return SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: SizedBox(
        width: double.maxFinite,
        child: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 24,
              child: viewModel.address.label.icon(T.colorScheme.primary),
            ),
            Text(
              viewModel.address.label.label,
              style: TextStyle(
                color: T.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: T.colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: T.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: const Color.fromRGBO(35, 44, 79, 1),
      ),
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(
              text: viewModel.address.address,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SelectableText.rich(
                  formattedAddress(viewModel.address.address),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Icon(Icons.copy),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFullPage() async {
    viewModel.isFullPage = !viewModel.isFullPage;
  }

  Future<void> _showBottomSheet(final BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (final context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF273765),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _buildBottomSheet(context),
        ),
      ),
    );
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, top: 16),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: T.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(512),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: T.colorScheme.onSurface,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  L.address_type,
                  style: TextStyle(
                    color: T.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildModalContent(context),
          ),
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildModalContent(final BuildContext context) {
    return Column(
      children: [
        ...List.generate(
          viewModel.wallet.address.length,
          (final int i) {
            final address = viewModel.wallet.address[i];
            final bool selected = i == viewModel.currentAddressOffset;
            return Card.filled(
              margin: EdgeInsets.all(0),
              shape: _getShape(viewModel.wallet.address.length, i),
              child: ListTile(
                shape: _getShape(viewModel.wallet.address.length, i),
                tileColor: selected
                    ? T.colorScheme.surfaceContainerHigh
                    : T.colorScheme.surfaceContainerLow,
                leading: address.label.icon(T.colorScheme.primary),
                title: Text(address.label.label),
                subtitle: Text(address.label.extra),
                trailing: selected
                    ? Icon(Icons.check_circle_sharp, size: 32, color: T.colorScheme.primary)
                    : null,
                onTap: () {
                  viewModel.currentAddressOffset = i;
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  RoundedRectangleBorder _getShape(final int count, final int current) {
    if (current == 0) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      );
    }
    if (current + 1 == count) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      );
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(),
    );
  }
}
