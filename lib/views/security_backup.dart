import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/alert.dart';
import 'package:cup_cake/view_model/security_backup_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/initial_setup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecurityBackup extends AbstractView {
  SecurityBackup({super.key, required this.viewModel});

  static Future<void> staticPush(
      BuildContext context, CoinWallet coinWallet) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return SecurityBackup(
            viewModel: SecurityBackupViewModel(
              wallet: coinWallet,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget? body(BuildContext context) {
    final details = viewModel.wallet.seedDetails(L);
    return ListView.builder(
      itemCount: details.length,
      itemBuilder: (BuildContext context, int index) {
        final d = details[index];
        switch (d.type) {
          case WalletSeedDetailType.text:
            return ListTile(
              title: Text(d.name),
              subtitle: SelectableText(
                d.value,
                style: const TextStyle(color: Colors.white),
              ),
            );
          case WalletSeedDetailType.qr:
            return LongPrimaryButton(
              text: d.name,
              icon: null,
              onPressed: () async {
                await _showQrCode(context, d);
              },
            );
        }
      },
    );
  }

  Future<void> _showQrCode(BuildContext context, WalletSeedDetail d) async {
    await showAlertWidget(
      context: context,
      title: d.name,
      body: [
        SizedBox.square(
          dimension: 300,
          child: QrImageView(
            data: d.value,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  SecurityBackupViewModel viewModel;
}
