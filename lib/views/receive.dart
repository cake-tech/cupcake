import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/receive_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receive extends AbstractView {
  Receive({super.key, required final CoinWallet coinWallet})
      : viewModel = ReceiveViewModel(coinWallet);

  @override
  final ReceiveViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
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
              child: QrImageView(
                data: "monero:${viewModel.address}",
                dataModuleStyle: QrDataModuleStyle(
                  color: Colors.black,
                  dataModuleShape: QrDataModuleShape.square,
                ),
                eyeStyle: QrEyeStyle(
                  color: Colors.black,
                  eyeShape: QrEyeShape.square,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: const Color.fromRGBO(35, 44, 79, 1),
            ),
            child: InkWell(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text: viewModel.address,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: SelectableText(
                      viewModel.address,
                      style: const TextStyle(color: Colors.white),
                    )),
                    const Icon(Icons.copy, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
