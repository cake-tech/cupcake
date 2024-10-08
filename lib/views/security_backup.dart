import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/security_backup_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(L.primary_address_label),
            subtitle: Text(viewModel.wallet.primaryAddress),
          ),
          QrImageView(
            data: viewModel.wallet.DO_NOT_MERGE_restoreData,
            foregroundColor: Colors.white,
          ),
          Text(viewModel.wallet.seed),
        ],
      ),
    );
  }

  @override
  SecurityBackupViewModel viewModel;
}
