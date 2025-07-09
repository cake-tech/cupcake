import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/bip39.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/new_wallet/action.dart';
import 'package:cupcake/views/verify_seed_page.dart';
import 'package:cupcake/views/widgets/seed_grid.dart';
import 'package:cupcake/views/widgets/yellow_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewWalletInfoPage {
  NewWalletInfoPage({
    required this.topText,
    required this.topAction,
    required this.topActionText,
    required this.svgIcon,
    required this.actions,
    required this.texts,
  });
  static NewWalletInfoPage preShowSeedPage(final AppLocalizations L, final ThemeData T) =>
      NewWalletInfoPage(
        topText: L.important,
        topAction: null,
        topActionText: null,
        svgIcon: Assets.icons.shieldKeys.svg(),
        actions: [
          NewWalletAction(
            type: NewWalletActionType.nextPage,
            function: null,
            text: L.understand_show_seed,
          ),
        ],
        texts: [
          Text(
            L.important_seed_backup_info,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: T.colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      );

  static NewWalletInfoPage writeDownNotice(
    final AppLocalizations L,
    final ThemeData T, {
    required final Future<void> Function()? nextCallback,
    required final String text,
    required final String title,
  }) =>
      NewWalletInfoPage(
        topText: L.seed,
        topAction: null,
        topActionText: null,
        svgIcon: null,
        actions: [
          NewWalletAction(
            type: NewWalletActionType.function,
            function: (final _) => Clipboard.setData(ClipboardData(text: text)),
            text: L.copy,
          ),
          NewWalletAction(
            type: NewWalletActionType.function,
            function: (final BuildContext context) async {
              for (var i = 0; i < 2; i++) {
                final isCorrect = await VerifySeedPage(
                  seedWords: text.split(" "),
                  wordList: Bip39.english,
                ).push(context);
                if (isCorrect != true) return;
              }
              await nextCallback?.call();
            },
            text: L.verify_seed,
          ),
        ],
        texts: [
          YellowWarning(text: L.save_words_warning, padding: EdgeInsets.zero),
          SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: T.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 32),
          Expanded(child: SeedPhraseGridWidget(list: text.split(" "))),
        ],
      );

  final String topText;
  final VoidCallback? topAction;
  final Widget? topActionText;

  final SvgPicture? svgIcon;
  final List<NewWalletAction> actions;

  List<Widget> texts;
}
