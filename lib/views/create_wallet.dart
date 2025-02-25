import 'package:cupcake/utils/types.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CreateWallet extends AbstractView {
  CreateWallet({
    super.key,
    required final CreateMethod createMethod,
    required final bool needsPasswordConfirm,
  }) : viewModel = CreateWalletViewModel(
          createMethod: createMethod,
          needsPasswordConfirm: needsPasswordConfirm,
        );

  @override
  final CreateWalletViewModel viewModel;

  Widget _selectCoin(final BuildContext context) {
    return ListView.builder(
      itemCount: viewModel.coins.length,
      itemBuilder: (final BuildContext context, final int index) {
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

  Widget _createMethod(final BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      child: ListView.builder(
        itemCount: viewModel.createMethods.keys.length,
        itemBuilder: (final BuildContext context, final int index) {
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

  @override
  Widget? body(final BuildContext context) {
    if (viewModel.selectedCoin == null) {
      return _selectCoin(context);
    }
    if (viewModel.currentForm == null) {
      return _createMethod(context);
    }
    return Column(
      children: [
        if (viewModel.isPinSet)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Assets.mobile.lottie(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FormBuilder(
            viewModel: FormBuilderViewModel(
              formElements: viewModel.currentForm!,
              scaffoldContext: context,
              isPinSet: viewModel.isPinSet,
              toggleIsPinSet: (final bool val) {
                viewModel.isPinSet = val;
              },
              showExtra: viewModel.showExtra,
              onLabelChange: viewModel.titleUpdate,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    if (!viewModel.isPinSet) return null;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LongPrimaryButton(
            text: L.next,
            icon: null,
            onPressed: viewModel.createWallet,
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
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    viewModel.register(context);
    return Observer(
      builder: (final BuildContext context) {
        return Scaffold(
          key: viewModel.scaffoldKey,
          appBar: appBar,
          body: SingleChildScrollView(child: body(context)),
          floatingActionButton: floatingActionButton(context),
          bottomNavigationBar: bottomNavigationBar(context),
        );
      },
    );
  }
}
