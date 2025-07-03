import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

part 'bdk_tx_test.g.dart';

class BDKPSBTViewModel = BDKPSBTViewModelBase with _$BDKPSBTViewModel;

abstract class BDKPSBTViewModelBase extends ViewModel with Store {
  BDKPSBTViewModelBase({
    required this.wallet,
  });

  @override
  String get screenName => L.scan;

  final CoinWallet wallet;

  @observable
  String status = "";
  @observable
  bool busy = false;

  void log(final dynamic value) {
    status += "\n$value";
    status = status.trim();
  }

  Future<void> _run() async {
    busy = true;
    status = "";
    log("createWalletObject");
    final w = (await Bitcoin().createWalletObject(wallet.seed)).w[0];
    log(w.getAddress(addressIndex: AddressIndex.peek(index: 0)).address.asString());
    log("creating config");
    final config = BlockchainConfig.electrum(
      config: ElectrumConfig(
        url: "ssl://btc-electrum.cakewallet.com:50002",
        retry: 5,
        stopGap: BigInt.from(50),
        validateDomain: false,
      ),
    );
    log("creating blockchain");
    final blockchain = await Blockchain.create(config: config);
    log("syncing");
    try {
      await w.sync(
        blockchain: blockchain,
      );
    } catch (e) {
      log(e);
    }
    log("done");
    log((w.getBalance().total.toInt() / 1e8).toStringAsFixed(8));
    log("creating addresses (1k)");
    for (var i = 0; i < 1000; i++) {
      w.getAddress(addressIndex: AddressIndex.increase());
    }
    final psbt = await PartiallySignedTransaction.fromString(
      "cHNidP8BAHECAAAAAdKLQbS4HhnB/MuYEqjOEpzd8/kTGraE6NqF0vnB7GPfAAAAAAD/////AlDDAAAAAAAAFgAUaXyHTaChttVprWwbuVyDxduR/Bnj9wEAAAAAABYAFP5EnxiEYlz2AxgEyGDMD8IA192tAAAAAAABAR/DvwIAAAAAABYAFJ+oANsY68w7Ewwy6Yz7s4r5rY7HIgYDOiWkNsuiP6TMX41+GmLqChr/LNCwCsqyRDKTLo7NmtsYAAAAAFQAAIAAAACAAAAAgAAAAAAAAAAAAAAiAgPtwyobZcT8BKCBakO23ImJt+xl+x/GCEIrT7ruxxziZhgAAAAAVAAAgAAAAIAAAACAAQAAACAAAAAA",
    );
    log("previous: ${psbt.asString()}");
    final output = await w.sign(
      psbt: psbt,
      signOptions: SignOptions(
        trustWitnessUtxo: true,
        allowAllSighashes: true,
        removePartialSigs: true,
        tryFinalize: true,
        signWithTapInternalKey: true,
        allowGrinding: true,
      ),
    );
    log("output: $output");
    log("next: ${psbt.asString()}");
    busy = false;
  }

  Future<void> run() => callThrowable(
        () async {
          try {
            await _run();
          } catch (e) {
            log(e);
            busy = false;
            rethrow;
          }
        },
        "run",
      );
}

class BDKPSBT extends AbstractView {
  BDKPSBT({
    super.key,
    required final CoinWallet wallet,
  }) : viewModel = BDKPSBTViewModel(wallet: wallet);

  @override
  final BDKPSBTViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Observer(builder: (final _) => SelectableText(viewModel.status)),
          Observer(builder: (final _) => (viewModel.busy) ? Container() : _buildConfirm()),
        ],
      ),
    );
  }

  Widget _buildConfirm() {
    return ElevatedButton(
      onPressed: viewModel.run,
      child: Text("Start test"),
    );
  }
}
