import 'dart:developer';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/coins/bitcoin/address.dart';
import 'package:cupcake/coins/bitcoin/amount.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/coins/bitcoin/wallet_info.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/views/animated_qr_page.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:ur/cbor_lite.dart';
import 'package:ur/ur.dart';
import 'package:ur/ur_encoder.dart';

class BDKWalletWrapper {
  BDKWalletWrapper({
    required final List<Wallet> wallets,
    required this.mnemonic,
    required this.xpub,
  }) : w = wallets;
  final List<Wallet> w;
  final Mnemonic mnemonic;
  String get currentAddress {
    return w[0].getAddress(addressIndex: AddressIndex.peek(index: 0)).address.asString();
  }

  final String xpub;

  Future<bool> sign({required final PartiallySignedTransaction psbt}) async {
    bool ret = false;
    var previous = psbt.asString();
    log(previous);
    for (final wallet in w) {
      ret = ret ||
          wallet.sign(
            psbt: psbt,
            signOptions: SignOptions(
              trustWitnessUtxo: true,
              allowAllSighashes: true,
              removePartialSigs: false,
              tryFinalize: true,
              signWithTapInternalKey: true,
              allowGrinding: true,
            ),
          );
      final next = psbt.asString();
      if (previous == next) {
        print("next is equal to previous, nothing changed");
      } else {
        print("previous different than next");
        log(next);
        previous = next;
      }
    }
    return ret;
  }
}

class BitcoinWallet implements CoinWallet {
  const BitcoinWallet(
    this.wallet, {
    required this.seed,
    required final String walletName,
  }) : _walletName = walletName;
  final BDKWalletWrapper wallet;

  @override
  List<String> get connectCakeWalletQRCode => [publicUri.toString()];

  @override
  int get addressIndex => 0;

  @override
  Future<void> close() async {} // no need

  @override
  Coin get coin => Bitcoin();

  @override
  int getAccountId() {
    return 0;
  }

  @override
  String get getAccountLabel => "Primary Address";

  @override
  int getAccountsCount() => 1;

  @override
  int getBalance() => -1;

  @override
  String getBalanceString() {
    final balance = getBalance();
    return (balance / 1e8).toStringAsFixed(8);
  }

  @override
  String get getCurrentAddress => wallet.currentAddress;

  @override
  Future<void> handleUR(final BuildContext context, final URQRData ur) async {
    switch (ur.tag) {
      case 'psbt' || '':
        // final psbt = await PartiallySignedTransaction.fromString(psbtBase64)
        // final psbt = /* works: some random PSBT I found online, signed */ await PartiallySignedTransaction.fromString("cHNidP8BAHECAAAAAW4TCBaK74DxafvrRdWpF32Gg5eVRs1DJX9YHz2v9jduAQAAAAD9////AugDAAAAAAAAFgAUlZYmgEZt2xztxXvON/MpazPDg7h4fAEAAAAAABYAFAos5SNG8ZD0bYuTY1T3lwWbt6XcC+8cAAABAN4CAAAAAAEBtxgls3RExZgey5D+Apcb7GIFdINeRlmY05VOQwZ7LtoBAAAAAP3///8CCgAAAAAAAAAWABSdRgMHmJrQiGsOWa+Ue5R6hDsGJlCBAQAAAAAAFgAUgIISApOAGqWF1K6dU+ANtN8F53kCRzBEAiAL3rtr0r5eB/U3HFRFKEWCJ/MuHEIetMi/5W/Pdw2tOAIgNSY0WkLk1lDHFxJIYgISnlr/0ZZu6YNExTLAGmgoca4BIQNc7DqYfFYpf3ejWJHMoMS+SGNnQh+QcpG8DXyPT1mnHgPvHAAiBgIDWK/NdMjNwkMIwK+D39jKrQQdd8QVK/Kmur/hQm0ACQy0x7YSAQAAAAEAAAAAIgICoL287OJyWbD9uT1ATxNQaD9VqKoAKdvQ6mRatmnd5zMMtMe2EgAAAAABAAAAACICAkaw3TsIUUYODFTLGB5brpjvHFDF7dG63Mg9m/KFHmMzDLTHthIBAAAAAgAAAAA=");
        // final psbt = /* works: Case: PSBT with one P2PKH input which has a non-final scriptSig and has a sighash type specified. Outputs are empty */ await PartiallySignedTransaction.fromString("cHNidP8BAHUCAAAAASaBcTce3/KF6Tet7qSze3gADAVmy7OtZGQXE8pCFxv2AAAAAAD+////AtPf9QUAAAAAGXapFNDFmQPFusKGh2DpD9UhpGZap2UgiKwA4fUFAAAAABepFDVF5uM7gyxHBQ8k0+65PJwDlIvHh7MuEwAAAQD9pQEBAAAAAAECiaPHHqtNIOA3G7ukzGmPopXJRjr6Ljl/hTPMti+VZ+UBAAAAFxYAFL4Y0VKpsBIDna89p95PUzSe7LmF/////4b4qkOnHf8USIk6UwpyN+9rRgi7st0tAXHmOuxqSJC0AQAAABcWABT+Pp7xp0XpdNkCxDVZQ6vLNL1TU/////8CAMLrCwAAAAAZdqkUhc/xCX/Z4Ai7NK9wnGIZeziXikiIrHL++E4sAAAAF6kUM5cluiHv1irHU6m80GfWx6ajnQWHAkcwRAIgJxK+IuAnDzlPVoMR3HyppolwuAJf3TskAinwf4pfOiQCIAGLONfc0xTnNMkna9b7QPZzMlvEuqFEyADS8vAtsnZcASED0uFWdJQbrUqZY3LLh+GFbTZSYG2YVi/jnF6efkE/IQUCSDBFAiEA0SuFLYXc2WHS9fSrZgZU327tzHlMDDPOXMMJ/7X85Y0CIGczio4OFyXBl/saiK9Z9R5E5CVbIBZ8hoQDHAXR8lkqASECI7cr7vCWXRC+B3jv7NYfysb3mk6haTkzgHNEZPhPKrMAAAAAAQMEAQAAAAAAAA");
        // final psbt = /* works: Let's breakdown another simple unsigned PSBT data with 1 input and 1 output: https://dev.to/eunovo/the-psbt-standard-i0d */  await PartiallySignedTransaction.fromString("cHNidP8BAFUCAAAAAetjNmGR26900wxt6Mu3II3j+2WtJmtBxWmQpafmourJAAAAAAD/////AQAXqAQAAAAAGXapFMF1K/W/+9Mgqyq2JbMrn+SDN9zkiKwAAAAAAAAA");
        // final psbt = /* works: bluewallet, bitcoin 4 test tx */ await PartiallySignedTransaction.fromString("cHNidP8BAHECAAAAAdZFS6gr5vBFXYPPDaInZ/8Gj0IdOjVq3Y3POQBRPC0pAQAAAAD/////AugDAAAAAAAAFgAUig3fG6xxMdKbhi116fv9mxBrsCMnuQIAAAAAABYAFP5EnxiEYlz2AxgEyGDMD8IA192tAAAAAAABAR8NwQIAAAAAABYAFNysLvPaozzk8soBWJaufHqcQxDCIgYCaRgIxGMs3hL+S5Sedt+KLM9hKUUES+BDDt1v+hZvhWUYAAAAAFQAAIAAAACAAAAAgAEAAAAfAAAAAAAiAgPtwyobZcT8BKCBakO23ImJt+xl+x/GCEIrT7ruxxziZhgAAAAAVAAAgAAAAIAAAACAAQAAACAAAAAA");
        // final psbt = /* works: bluewallet, bitcoin 4 test tx (2) */ await PartiallySignedTransaction.fromString("cHNidP8BAHECAAAAAdKLQbS4HhnB/MuYEqjOEpzd8/kTGraE6NqF0vnB7GPfAAAAAAD/////AlDDAAAAAAAAFgAUaXyHTaChttVprWwbuVyDxduR/Bnj9wEAAAAAABYAFP5EnxiEYlz2AxgEyGDMD8IA192tAAAAAAABAR/DvwIAAAAAABYAFJ+oANsY68w7Ewwy6Yz7s4r5rY7HIgYDOiWkNsuiP6TMX41+GmLqChr/LNCwCsqyRDKTLo7NmtsYAAAAAFQAAIAAAACAAAAAgAAAAAAAAAAAAAAiAgPtwyobZcT8BKCBakO23ImJt+xl+x/GCEIrT7ruxxziZhgAAAAAVAAAgAAAAIAAAACAAQAAACAAAAAA",);

        final psbt = await PartiallySignedTransaction.fromString(ur.base64);
        print(psbt.asString());

        final Map<BitcoinAddress, BitcoinAmount> destMap = {};
        final tx = psbt.extractTx();
        final outputs = tx.output();
        for (final out in outputs) {
          final bdkScript = out.scriptPubkey;
          final script = ScriptBuf(bytes: bdkScript.bytes);
          final address = await Address.fromScript(
            script: script,
            network: Network.bitcoin,
          );
          destMap[BitcoinAddress(address.toString())] = BitcoinAmount(out.value.toInt());
        }
        if (!context.mounted) return;

        await UnconfirmedTransactionView(
          wallet: this,
          destMap: destMap,
          fee: BitcoinAmount(psbt.feeAmount()?.toInt() ?? -1),
          confirmCallback: (final BuildContext context) async {
            final status = await wallet.sign(psbt: psbt);
            if (!status) throw Exception("Failed to sign");
            final sourceBytes = psbt.serialize();
            final cborEncoder = CBOREncoder();
            cborEncoder.encodeBytes(sourceBytes);
            final ur = UR("psbt", cborEncoder.getBytes());
            // var ur = UR("psbt", Uint8List.fromList(List.generate(64*1024, (int x) => x % 256)));
            final encoded = UREncoder(ur, 120);
            final List<String> values = [];
            while (!encoded.isComplete) {
              values.add(encoded.nextPart());
            }
            if (!context.mounted) return;
            await AnimatedURPage(
              urqrList: {"signedTx": values},
              currentWallet: this,
            ).pushReplacement(context);
          },
          cancelCallback: () => Navigator.of(context).pop(),
        ).pushReplacement(context);
        break;
      default:
        throw Exception("Unable to handle '${ur.tag}' UR tag");
    }
  }

  @override
  bool get hasAccountSupport => false;

  @override
  bool get hasAddressesSupport => true;

  @override
  String get passphrase => "";

  @override
  String get primaryAddress => wallet.currentAddress;

  @override
  final String seed;

  @override
  Future<List<WalletSeedDetail>> seedDetails() async {
    return [
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: "Seed",
        value: seed,
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: "xPub",
        value: wallet.xpub,
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.qr,
        name: "Pair Cake Wallet",
        value: publicUri.toString(),
      ),
    ];
  }

  Uri get publicUri => Uri(
        scheme: "bitcoin",
        queryParameters: {
          "xpub": wallet.xpub,
          // "path": wallet.derivationPath,
          "label": p.basename(walletName),
        },
      );

  @override
  void setAccount(final int newAccountIndex) {}

  @override
  String get walletName => p.basename(_walletName);

  final String _walletName;

  @override
  CoinWalletInfo get walletInfo => BitcoinWalletInfo(walletName);
}
