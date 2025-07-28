import 'dart:convert';

import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/view_model/security_backup_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:cupcake/views/widgets/security_backup_tabbed_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SecurityBackup extends AbstractView {
  SecurityBackup({
    super.key,
    required final CoinWallet coinWallet,
  }) : viewModel = SecurityBackupViewModel(
          wallet: coinWallet,
        );

  @override
  SecurityBackupViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return Expanded(
      child: Observer(
        builder: (final BuildContext context) {
          if (viewModel.isLocked) {
            return FormBuilder(
              showExtra: true,
              viewModel: viewModel.formBuilderViewModel,
            );
          }

          return SecurityBackupTabbedContent(
            viewModel: viewModel,
            getDetails: getDetails,
            L: L,
          );
        },
      ),
    );
  }

  Future<List<WalletSeedDetail>> getDetails() async {
    var details = await viewModel.wallet.seedDetails();
    details = details.where((final e) => e.type == WalletSeedDetailType.text).toList();
    if (CupcakeConfig.instance.debug) {
      final secrets = await secureStorage.readAll();

      details.addAll(
        List.generate(
          secrets.keys.length,
          (final index) {
            final key = secrets.keys.elementAt(index);
            return WalletSeedDetail(
              type: WalletSeedDetailType.text,
              name: key,
              value: secrets[key] ?? "unknown",
            );
          },
        ),
      );
      details.addAll(
        List.generate(
          CupcakeConfig.instance.toJson().keys.length,
          (final index) {
            final key = CupcakeConfig.instance.toJson().keys.elementAt(index);
            return WalletSeedDetail(
              type: WalletSeedDetailType.text,
              name: key,
              value: const JsonEncoder.withIndent('    ').convert(
                CupcakeConfig.instance.toJson()[key],
              ),
            );
          },
        ),
      );
    }
    return details;
  }
}
