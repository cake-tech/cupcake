import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:cupcake/views/widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CreateWallet extends AbstractView {
  CreateWallet({
    super.key,
    required final CreateMethod? createMethod,
    required final bool needsPasswordConfirm,
  }) : viewModel = CreateWalletViewModel(
          createMethod: createMethod,
          needsPasswordConfirm: needsPasswordConfirm,
        );

  @override
  bool get hasBackground => true;

  @override
  final CreateWalletViewModel viewModel;

  Widget _selectCoin(final BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 48),
        Text(L.choose_wallet_currency),
        SizedBox(height: 8),
        ...List.generate(
          viewModel.coins.length,
          (final int i) => Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: CakeListTile(
              onTap: (final BuildContext _) {
                viewModel.selectedCoin = viewModel.coins[i];
              },
              icon: viewModel.coins[i].strings.svg,
              text: viewModel.coins[i].strings.nameFull,
            ),
          ),
        ),
      ],
    );
  }

  Widget _createMethodKind(final BuildContext context) {
    return SizedBox(
      height: double.maxFinite,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 250,
            child: Assets.icons.walletNew.svg(),
          ),
          Padding(
            padding: const EdgeInsets.all(42.0),
            child: Text.rich(
              markdownText(L.wallet_creation_onboard),
              style: TextStyle(color: T.colorScheme.onSurface, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 86.0),
            child: Text(
              L.wallet_creation_kind_note,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          LongSecondaryButton(
            T,
            onPressed: () {
              viewModel.createMethod = CreateMethod.create;
            },
            text: L.restore_wallet,
          ),
          LongPrimaryButton(
            onPressed: () {
              viewModel.createMethod = CreateMethod.create;
            },
            text: L.create_new_wallet,
          ),
        ],
      ),
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
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: CakeListTile(
              onTap: (final BuildContext _) {
                viewModel.currentForm = value;
              },
              text: key,
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
    if (viewModel.createMethod == null) {
      return _createMethodKind(context);
    }
    if (viewModel.currentForm == null) {
      return _createMethod(context);
    }
    return Column(
      children: [
        if (viewModel.isPinSet)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 64.0,
              vertical: 64,
            ),
            child: Assets.icons.walletNewName.svg(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FormBuilder(
            showExtra: viewModel.showExtra,
            viewModel: FormBuilderViewModel(
              formElements: viewModel.currentForm!.form,
              scaffoldContext: context,
              isPinSet: viewModel.isPinSet,
              toggleIsPinSet: (final bool val) {
                viewModel.isPinSet = val;
              },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.hasAdvancedOptions)
          LongSecondaryButton(
            T,
            text: L.advanced_options,
            onPressed: () {
              viewModel.showExtra = !viewModel.showExtra;
            },
          ),
        LongPrimaryButton(
          text: L.next,
          icon: null,
          onPressed: viewModel.createWallet,
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    viewModel.register(context);
    return Observer(
      builder: (final BuildContext context) {
        return super.build(context);
      },
    );
  }
}
