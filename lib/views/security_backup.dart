import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/alerts/widget.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/view_model/security_backup_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecurityBackup extends AbstractView {
  SecurityBackup({
    super.key,
    required final CoinWallet coinWallet,
  }) : viewModel = SecurityBackupViewModel(
          wallet: coinWallet,
        );

  @override
  SecurityBackupViewModel viewModel;

  Future<void> _copy(final BuildContext context, final String value, final String key) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L.copied(key)),
      ),
    );
  }

  @override
  Widget? body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) {
        if (viewModel.isLocked) {
          return FormBuilder(
            showExtra: true,
            viewModel: FormBuilderViewModel(
              formElements: viewModel.form,
              scaffoldContext: context,
              isPinSet: !viewModel.isLocked,
            ),
          );
        }
        final details = viewModel.wallet.seedDetails();
        return FutureBuilder(
          future: details,
          builder: (final BuildContext context, final snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.error != null) {
                return Text(snapshot.error.toString());
              }
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (final BuildContext context, final int index) {
                return _buildElement(context, snapshot.data![index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildElement(final BuildContext context, final WalletSeedDetail d) {
    switch (d.type) {
      case WalletSeedDetailType.text:
        return ListTile(
          onTap: () async {
            await _copy(context, d.value, d.name);
          },
          title: Text(
            d.name,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            d.value,
            style: const TextStyle(color: Colors.white),
          ),
        );
      case WalletSeedDetailType.qr:
        return LongPrimaryButton(
          text: d.name,
          icon: Icons.qr_code_rounded,
          onPressed: () async {
            await _showQrCode(context, d, color: Colors.transparent, color2: Colors.white);
          },
        );
    }
  }

  Future<void> _showQrCode(
    final BuildContext context,
    final WalletSeedDetail d, {
    final Color color = Colors.black,
    final Color? color2,
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
            dataModuleStyle: QrDataModuleStyle(
              color: color2 ?? Colors.black,
              dataModuleShape: QrDataModuleShape.square,
            ),
            eyeStyle: QrEyeStyle(
              color: color2 ?? Colors.black,
              eyeShape: QrEyeShape.square,
            ),
          ),
        ),
      ],
    );
  }
}
