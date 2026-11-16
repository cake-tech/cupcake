import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/zcash/coin.dart';
import 'package:cupcake/coins/zcash/creation/new_wallet.dart';
import 'package:cupcake/coins/zcash/creation/seed_restore.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';
import 'package:cupcake/utils/types.dart';

class ZcashWalletCreation extends WalletCreation {
  factory ZcashWalletCreation(final AppLocalizations L) {
    _instance ??= ZcashWalletCreation._internal(L);
    return _instance!;
  }
  ZcashWalletCreation._internal(this.L);
  static ZcashWalletCreation? _instance;

  AppLocalizations L;

  late List<FormElement> createForm = [seedOffset, seedOffsetConfrm];
  late List<FormElement> restoreFromSeedForm = [seed, seedOffset, seedOffsetConfrm];

  late StringFormElement seed = StringFormElement(
    L.seed,
    password: true,
    isExtra: false,
    validator: nonEmptyValidator(
      L,
      extra: (final input) =>
          !(coin.isSeedSomewhatLegit(input)) ? L.warning_seed_incorrect_length : null,
    ),
    errorHandler: errorHandler,
    canPaste: true,
  );

  late StringFormElement seedOffset = StringFormElement(
    L.seed_offset,
    password: true,
    isExtra: true,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
    canPaste: true,
  );

  late StringFormElement seedOffsetConfrm = StringFormElement(
    L.seed_offset_confirm,
    password: true,
    isExtra: true,
    validator: (final String? input) =>
        input != seedOffset.ctrl.text ? L.seed_passphrase_mismatch : null,
    errorHandler: errorHandler,
    canPaste: true,
  );

  @override
  Coin get coin => Zcash();

  Future<void> errorHandler(final Object error) async {
    print("error: $error");
    return;
  }

  @override
  Future<CreationOutcome?> create(
    final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  ) async {
    if (createMethod == CreateMethod.create) {
      return CreateZcashWalletCreationMethod(
        L,
        walletPath: coin.getPathForWallet(walletName),
        walletPassword: walletPassword,
        seedOffsetOrEncryption: await seedOffset.value,
      ).create();
    } else if (createMethod == CreateMethod.restore) {
      return SeedRestoreZcashWalletCreationMethod(
        L,
        walletPath: coin.getPathForWallet(walletName),
        walletPassword: walletPassword,
        seedOffsetOrEncryption: await seedOffset.value,
        seed: await seed.value,
      ).create();
    }
    return null;
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
          L.option_create_seed: WalletCreationForm(
            method: CreateMethod.restore,
            form: restoreFromSeedForm,
          ),
        },
      };

  @override
  void wipe() {
    seedOffset.clear();
    seedOffsetConfrm.clear();
  }
}
