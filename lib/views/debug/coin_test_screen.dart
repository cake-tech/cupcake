import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/debug/coin_test.dart';
import 'package:cupcake/coins/debug/test_cases.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class CoinTestViewModel extends ViewModel {
  @override
  String get screenName => "Coin tests";

  final Observable<String> status = Observable("");
  final Observable<bool> busy = Observable(false);

  void log(final String line) {
    runInAction(() => status.value = "${status.value}\n$line".trimLeft());
  }

  Future<void> run() async {
    if (busy.value) return;
    runInAction(() {
      busy.value = true;
      status.value = "";
    });

    Coin.L = L;
    final results = CoinTestResults();
    try {
      for (final coin in walletCoins) {
        log("");
        log("=== ${coin.strings.nameFull} ===");
        if (!coin.isEnabled) {
          results.skipped++;
          log("SKIP: native library unavailable");
          continue;
        }
        await runCoinTests(coinTestCases(coin), log, results);
      }
    } catch (e, s) {
      results.failed++;
      log("FAIL harness crashed: $e\n$s");
    }
    log("");
    log(results.ok ? "ALL OK: $results" : "FAILURES: $results");
    runInAction(() => busy.value = false);
  }
}

class CoinTestScreen extends AbstractView {
  CoinTestScreen({super.key});

  @override
  final CoinTestViewModel viewModel = CoinTestViewModel();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget? body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) {
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          if (!_scrollController.hasClients) return;
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SelectableText(
            viewModel.status.value.isEmpty
                ? "Restores known test wallets, checks the derived addresses and\n"
                    "signs prepared transactions offline."
                : viewModel.status.value,
            style: const TextStyle(fontFamily: "monospace", fontSize: 12),
          ),
        );
      },
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) => LongPrimaryButton(
        text: viewModel.busy.value ? "Running..." : "Run all coin tests",
        onPressed: viewModel.busy.value ? null : viewModel.run,
      ),
    );
  }
}
