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

  late List<FormElement> createForm = [];
  late List<FormElement> restoreForm = [seed];

  @override
  Future<CreationOutcome?> create(
    final CreateMethod createMethod,
    final String walletName,
    final String walletPassword,
  ) async {
    return switch (createMethod) {
      CreateMethod.create => CreateLitecoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
        ).create(),
      CreateMethod.restore => RestoreLitecoinWalletCreationMethod(
          L,
          walletPath: coin.getPathForWallet(walletName),
          walletPassword: walletPassword,
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
  void wipe() {}

  @override
  Coin get coin => Litecoin();
}
