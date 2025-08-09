import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/coins/bitcoin/creation/new_wallet.dart';
import 'package:cupcake/coins/bitcoin/creation/restore_wallet.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/utils/types.dart';

class BitcoinWalletCreation extends WalletCreation {
  factory BitcoinWalletCreation(final AppLocalizations L) {
    _instance ??= BitcoinWalletCreation._internal(L);
    return _instance!;
  }
  BitcoinWalletCreation._internal(this.L);
  static BitcoinWalletCreation? _instance;

  final AppLocalizations L;

  Future<void> errorHandler(final Object error) async {
    print("error: $error");
    return;
  }

  late StringFormElement seed = StringFormElement(
    L.wallet_seed,
    password: false,
    validator: nonEmptyValidator(
      L,
      extra: (final input) =>
          !(Bitcoin().isSeedSomewhatLegit(input)) ? L.warning_seed_incorrect_length : null,
    ),
    errorHandler: errorHandler,
    canPaste: true,
  );

  late StringFormElement passphrase = StringFormElement(
    L.wallet_passphrase,
    password: false,
    validator: nonEmptyValidator(
      L,
      extra: (final input) => null,
    ),
    errorHandler: errorHandler,
    canPaste: true,
    isExtra: true,
  );

  late List<FormElement> createForm = [passphrase];
  late List<FormElement> restoreForm = [seed, passphrase];

  @override
  Future<CreationOutcome?> create(
    final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  ) async {
    return switch (createMethod) {
      CreateMethod.create => CreateBitcoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
          passphrase: await passphrase.value,
        ).create(),
      CreateMethod.restore => RestoreBitcoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
          seed: await seed.value,
          passphrase: await passphrase.value,
        ).create(),
    };
  }

  @override
  Future<void> wipe() async {
    await Future.delayed(Duration.zero); // do not call on build();
    seed.ctrl.clear();
    passphrase.ctrl.clear();
  }

  @override
  Map<String, WalletCreationForm> createMethods(
    final CreateMethod createMethod,
  ) =>
      {
        if ([CreateMethod.create].contains(createMethod))
          L.option_create_new_wallet: WalletCreationForm(
            method: CreateMethod.create,
            form: createForm,
          ),
        if ([CreateMethod.restore].contains(createMethod)) ...{
          L.option_create_seed: WalletCreationForm(method: CreateMethod.restore, form: restoreForm),
        },
      };

  @override
  Coin get coin => Bitcoin();
}
