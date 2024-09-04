import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CreateWallet extends AbstractView {
  CreateWallet({super.key});

  @override
  Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return CreateWallet();
        },
      ),
    );
  }

  @override
  final CreateWalletViewModel viewModel = CreateWalletViewModel();

  @override
  Widget? body(BuildContext context) {
    if (viewModel.selectedCoin == null) {
      return ListView.builder(
        itemCount: viewModel.coins.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              viewModel.selectedCoin = viewModel.coins[index];
              markNeedsBuild(context);
            },
            child: Card(
              child: ListTile(
                title: Text(viewModel.coins[index].strings.nameFull),
              ),
            ),
          );
        },
      );
    }
    return Column(children: [
      FormBuilder(formElements: viewModel.creationForm),
    ]);
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    if (viewModel.selectedCoin == null) return null;
    return FloatingActionButton(
      child: const Icon(Icons.navigate_next),
      onPressed: () => callThrowable(
          context, () async => await _createWallet(context), "Creating wallet"),
    );
  }

  Future<void> _createWallet(BuildContext context) async {
    for (var element in viewModel.creationForm) {
      if (!element.isOk) {
        if (kDebugMode) {
          print("${element.label} is not valid: ");
        }
        return;
      }
    }
    await viewModel.createWallet();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body(context),
      floatingActionButton: floatingActionButton(context),
    );
  }
}
