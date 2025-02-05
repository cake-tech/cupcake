import 'package:cupcake/coins/types.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/material.dart';

class CreateWallet extends AbstractView {
  CreateWallet(
      {super.key,
      required CreateMethod createMethod,
      required bool needsPasswordConfirm})
      : viewModel = CreateWalletViewModel(
            createMethod: createMethod,
            needsPasswordConfirm: needsPasswordConfirm);

  @override
  final CreateWalletViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    if (viewModel.selectedCoin == null) {
      return ListView.builder(
        itemCount: viewModel.coins.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              viewModel.selectedCoin = viewModel.coins[index];
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
      return SizedBox(
        height: double.maxFinite,
        child: ListView.builder(
          itemCount: viewModel.createMethods.keys.length,
          itemBuilder: (BuildContext context, int index) {
            final key = viewModel.createMethods.keys.elementAt(index);
            final value = viewModel.createMethods[key];
            return InkWell(
              onTap: () {
                viewModel.currentForm = value;
              },
              child: Card(
                child: ListTile(
                  title: Text(key),
                ),
              ),
            );
          },
        ),
      );
    }
    formBuilder = FormBuilder(
      formElements: viewModel.currentForm ?? [],
      scaffoldContext: context,
      rebuild: (bool val) {
         viewModel.isPinSet = val;
      },
      isPinSet: viewModel.isPinSet,
      showExtra: viewModel.showExtra,
      onLabelChange: viewModel.titleUpdate,
    );
    return Column(
      children: [
        if (viewModel.isPinSet)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Assets.mobile.lottie(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: formBuilder,
        ),
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    if (viewModel.isPinSet) {
      return SafeArea(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LongPrimaryButton(
            text: L.next,
            icon: null,
            onPressed: () => _next(context),
            backgroundColor: const WidgetStatePropertyAll(Colors.green),
            textColor: Colors.white,
          ),
          if (viewModel.hasAdvancedOptions)
            LongPrimaryButton(
              text: L.advanced_options,
              icon: null,
              onPressed: () {
                viewModel.showExtra = true;
              },
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          const SizedBox(height: 16),
        ],
      ));
    }
    return null;
  }

  void _next(BuildContext context) async {
    await callThrowable(context,
        () async => await viewModel.createWallet(context), L.creating_wallet);
  }

  FormBuilder? formBuilder;

  bool isFormBad(List<FormElement> form) {
    for (var element in form) {
      if (!element.isOk) {
        if (CupcakeConfig.instance.debug) {
          print("${element.label} is not valid: ");
        }
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    viewModel.register(context);
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(child: body(context)),
      floatingActionButton: floatingActionButton(context),
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }
}
