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
    return FutureBuilder(
        future: details,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) return Text(snapshot.error.toString());
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final d = snapshot.data![index];
              switch (d.type) {
                case WalletSeedDetailType.text:
                  return ListTile(
                    title: Text(d.name,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    subtitle: SelectableText(
                      d.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                case WalletSeedDetailType.qr:
                  return LongPrimaryButton(
                    text: d.name,
                    icon: Icons.qr_code_rounded,
                    onPressed: () async {
                      await _showQrCode(context, d, color: Colors.transparent);
                    },
                  );
              }
            },
          );
        });
  }

  Future<void> _showQrCode(
    BuildContext context,
    WalletSeedDetail d, {
    Color color = Colors.black,
  }) async {
    await showAlertWidget(
      context: context,
      title: d.name,
      body: [
        SizedBox.square(
          dimension: 300,
          child: QrImageView(
            data: d.value,
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  SecurityBackupViewModel viewModel;
}
