import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/security_backup_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:flutter/cupertino.dart';

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
          Text(viewModel.wallet.seed),
        ],
      ),
    );
  }

  @override
  SecurityBackupViewModel viewModel;
}
