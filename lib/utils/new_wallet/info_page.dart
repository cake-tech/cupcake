import 'package:cupcake/utils/types.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/new_wallet/action.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

class NewWalletInfoPage {
  NewWalletInfoPage({
    required this.topText,
    required this.topAction,
    required this.topActionText,
    required this.lottieAnimation,
    required this.actions,
    required this.texts,
  });
  static NewWalletInfoPage preShowSeedPage(final AppLocalizations L) => NewWalletInfoPage(
        topText: L.important,
        topAction: null,
        topActionText: null,
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.nextPage,
            function: null,
            text: Text(
              L.understand_show_seed,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            L.important_seed_backup_info(L.seed_length_16_word),
            textAlign: TextAlign.center,
          ),
        ],
      );

  static NewWalletInfoPage writeDownNotice(
    final AppLocalizations L, {
    required final Future<void> Function()? nextCallback,
    required final String text,
    required final String title,
  }) =>
      NewWalletInfoPage(
        topText: L.seed,
        topAction: nextCallback,
        topActionText: Text(L.next),
        lottieAnimation: Assets.shield.lottie(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () {
              Share.share(text);
            },
            text: Text(
              L.save,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
          NewWalletAction(
            type: NewWalletActionType.function,
            function: () async {
              await Clipboard.setData(ClipboardData(text: text));
            },
            text: Text(
              L.copy,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
        texts: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "$text\n\n\n\n${L.write_down_notice}",
            textAlign: TextAlign.center,
          ),
        ],
      );

  final String topText;
  final VoidCallback? topAction;
  final Widget? topActionText;

  final LottieBuilder? lottieAnimation;
  final List<NewWalletAction> actions;

  List<Widget> texts;
}
