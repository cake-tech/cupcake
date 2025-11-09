import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/coins/litecoin/creation/new_wallet.dart';
import 'package:cupcake/coins/litecoin/creation/restore_wallet.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/utils/types.dart';

class LitecoinWalletCreation extends WalletCreation {
  factory LitecoinWalletCreation(final AppLocalizations L) {
    _instance ??= LitecoinWalletCreation._internal(L);
    return _instance!;
  }
  LitecoinWalletCreation._internal(this.L);
  static LitecoinWalletCreation? _instance;

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
          !(Litecoin().isSeedSomewhatLegit(input)) ? L.warning_seed_incorrect_length : null,
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

  late StringFormElement passphraseConfirm = StringFormElement(
    L.wallet_passphrase,
    password: false,
    validator: nonEmptyValidator(
      L,
      extra: (final input) => input != passphrase.ctrl.text ? L.seed_passphrase_mismatch : null,
    ),
    errorHandler: errorHandler,
    canPaste: true,
    isExtra: true,
  );

  late List<FormElement> createForm = [passphrase, passphraseConfirm];
  late List<FormElement> restoreForm = [passphrase, seed];

  @override
  Future<CreationOutcome?> create(
    final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  ) async {
    if (createMethod == CreateMethod.create &&
        (await passphrase.value != await passphraseConfirm.value)) {
      throw Exception("Passphrase doesn't match");
    }
    return switch (createMethod) {
      CreateMethod.create => CreateLitecoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
          passphrase: await passphrase.value,
          passphraseConfirm: await passphrase.value,
        ).create(),
      CreateMethod.restore => RestoreLitecoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
          passphrase: await passphrase.value,
          seed: await seed.value,
        ).create(),
    };
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
  Future<void> wipe() async {
    await Future.delayed(Duration.zero); // do not call on build();
    seed.ctrl.clear();
    passphrase.ctrl.clear();
    passphraseConfirm.ctrl.clear();
  }

  @override
  Coin get coin => Litecoin();
}
