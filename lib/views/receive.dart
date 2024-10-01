import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/receive_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receive extends AbstractView {
  static Future<void> pushStatic(BuildContext context, CoinWallet coin) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return Receive(
            ReceiveViewModel(coin),
          );
        },
      ),
    );
  }

  Receive(this.viewModel, {super.key});

  @override
  final ReceiveViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 48, right: 48, bottom: 32),
            child: QrImageView(
              data: "monero:${viewModel.address}",
              foregroundColor: Colors.white,
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(
                ClipboardData(
                  text: viewModel.address,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: SelectableText(
                    viewModel.address,
                    style: const TextStyle(color: Colors.white),
                  )),
                  const Icon(Icons.copy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}