import 'package:cup_cake/gen/assets.gen.dart';
import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/initial_setup_screen.dart';
import 'package:cup_cake/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CreateWallet extends AbstractView {
  CreateWallet({super.key, required this.viewModel});

  static Future<void> staticPush(
      BuildContext context, CreateWalletViewModel viewModel) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return CreateWallet(
            viewModel: viewModel,
          );
        },
      ),
    );
  }

  @override
  final CreateWalletViewModel viewModel;

  void setPinSet(BuildContext context, bool val) {
    print("setPinSet: $val");
    viewModel.isPinSet = val;
    markNeedsBuild(context);
  }

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
    if (viewModel.currentForm == null) {
      return ListView.builder(
        itemCount: viewModel.createMethods.keys.length,
        itemBuilder: (BuildContext context, int index) {
          final key = viewModel.createMethods.keys.elementAt(index);
          final value = viewModel.createMethods[key];
          return InkWell(
            onTap: () {
              viewModel.currentForm = value;
              markNeedsBuild(context);
            },
            child: Card(
              child: ListTile(
                title: Text(key),
              ),
            ),
          );
        },
      );
    }
    formBuilder = FormBuilder(
      formElements: viewModel.currentForm ?? [],
      scaffoldContext: context,
      rebuild: (bool val) => setPinSet(context, val),
      isPinSet: viewModel.isPinSet,
    );
    return Column(children: [
      if (viewModel.isPinSet)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0),
          child: Assets.mobile.lottie(),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: formBuilder,
      ),
      if (viewModel.isPinSet) const Spacer(),
      if (viewModel.isPinSet)
        LongPrimaryButton(
          text: L.next,
          icon: null,
          onPressed: () => _next(context),
          backgroundColor: const MaterialStatePropertyAll(Colors.green),
          textColor: Colors.white,
        ),
      if (viewModel.isPinSet)
        LongPrimaryButton(
          text: L.advanced_options,
          icon: null,
          onPressed: () {}, // TODO: passphrase
          backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
        ),
    ]);
  }

  void _next(BuildContext context) async {
    await callThrowable(context,
        () async => await viewModel.createWallet(context), L.creating_wallet);
  }

  FormBuilder? formBuilder;

  // @override
  // Widget? floatingActionButton(BuildContext context) {
  //   if (viewModel.selectedCoin == null) return null;
  //   return FloatingActionButton(
  //     child: const Icon(Icons.navigate_next),
  //     onPressed: () => _createWallet(context),
  //   );
  // }

  bool isFormBad(List<FormElement> form) {
    for (var element in form) {
      if (!element.isOk) {
        if (kDebugMode) {
          print("${element.label} is not valid: ");
        }
        return true;
      }
    }
    return false;
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
