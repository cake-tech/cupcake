// creation = any action that results in new wallet being created, be that restore or generate
// To unify the process of wallet creation we provide multiple "generators".
// There is one class that defines inputs (FormElement)
// And multiple WalletCreation classes
// When creating wallet heuristic are being applied to see which creation method will be used,
// it is entirely possible for one input of restore/creation form to have multiple outputs,

import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/creation/new_wallet.dart';
import 'package:cupcake/coins/monero/creation/restore_keys.dart';
import 'package:cupcake/coins/monero/creation/restore_legacy.dart';
import 'package:cupcake/coins/monero/creation/restore_polyseed.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/utils/form/single_choice_form_element.dart';
import 'package:cupcake/utils/form/string_form_element.dart';
import 'package:cupcake/utils/form/validators.dart';

class MoneroWalletCreation extends WalletCreation {
  factory MoneroWalletCreation(final AppLocalizations L) {
    _instance ??= MoneroWalletCreation._internal(L);
    return _instance!;
  }
  MoneroWalletCreation._internal(this.L);
  static MoneroWalletCreation? _instance;

  @override
  Future<void> wipe() async {
    await Future.delayed(Duration.zero); // do not call on build();
    seed.ctrl.clear();
    walletAddress.ctrl.clear();
    secretSpendKey.ctrl.clear();
    restoreHeight.ctrl.clear();
    seedOffset.ctrl.clear();
    walletSeedType.currentSelection = 0;
  }

  AppLocalizations L;

  @override
  final coin = Monero();

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
          !(Monero().isSeedSomewhatLegit(input)) ? L.warning_seed_incorrect_length : null,
    ),
    errorHandler: errorHandler,
  );

  late StringFormElement walletAddress = StringFormElement(
    L.primary_address_label,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
  );

  late StringFormElement secretSpendKey = StringFormElement(
    L.secret_spend_key,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
  );

  late StringFormElement secretViewKey = StringFormElement(
    L.secret_view_key,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
  );

  late StringFormElement restoreHeight = StringFormElement(
    L.restore_height,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
  );

  late StringFormElement seedOffset = StringFormElement(
    L.seed_offset,
    password: true,
    isExtra: true,
    validator: nonEmptyValidator(L),
    errorHandler: errorHandler,
  );

  late SingleChoiceFormElement walletSeedType = SingleChoiceFormElement(
    title: L.seed_type,
    elements: [
      L.seed_type_polyseed,
      L.seed_type_legacy,
    ],
    errorHandler: errorHandler,
  );

  late List<FormElement> createForm = [walletSeedType, seedOffset];

  late List<FormElement> restoreSeedForm = [seed, seedOffset];

  late List<FormElement> restoreKeysForm = [
    walletAddress,
    secretSpendKey,
    secretViewKey,
  ];

  @override
  Map<String, List<FormElement>> createMethods(final CreateMethod createMethod) => {
        if ([CreateMethod.create].contains(createMethod)) L.option_create_new_wallet: createForm,
        if ([CreateMethod.restore].contains(createMethod)) ...{
          L.option_create_seed: restoreSeedForm,
          L.option_create_keys: restoreKeysForm,
        },
      };

  @override
  Future<CreationOutcome> create(
    final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  ) async {
    if (createMethod == CreateMethod.create) {
      return CreateMoneroWalletCreationMethod(
        L,
        progressCallback: null,
        walletPath: coin.getPathForWallet(walletName),
        walletPassword: walletPassword,
        seedOffsetOrEncryption: await seedOffset.value,
      ).create();
    }

    if ((await seed.value).isNotEmpty && (await secretSpendKey.value).isNotEmpty) {
      // This shouldn't happen because of how UI works, but I'd like to be extra sure about it
      throw Exception(L.warning_restore_from_seed_and_key);
    }
    if ((await seed.value).isNotEmpty) {
      switch ((await seed.value).split(" ").length) {
        case 16:
          return RestorePolyseedMoneroWalletCreationMethod(
            L,
            walletPath: coin.getPathForWallet(walletName),
            walletPassword: walletPassword,
            seed: await seed.value,
            seedOffsetOrEncryption: await seedOffset.value,
          ).create();
        case 25:
          return RestoreLegacyWalletCreationMethod(
            L,
            walletPath: coin.getPathForWallet(walletName),
            walletPassword: walletPassword,
            seed: await seed.value,
            seedOffsetOrEncryption: await seedOffset.value,
          ).create();
        default:
          throw Exception(L.warning_input_seed_length_invalid);
      }
    }

    print(await walletAddress.value);
    print(await secretSpendKey.value);
    print(await secretViewKey.value);

    return RestoreFromKeysMoneroWalletCreationMethod(
      L,
      walletPath: coin.getPathForWallet(walletName),
      walletPassword: walletPassword,
      walletAddress: await walletAddress.value,
      secretSpendKey: await secretSpendKey.value,
      secretViewKey: await secretViewKey.value,
      restoreHeight: int.tryParse(await restoreHeight.value) ?? 1,
    ).create();
  }
}
