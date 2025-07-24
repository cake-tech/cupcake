import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:cupcake/views/widgets/custom_tab_bar.dart';
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
  final CreateWalletViewModel viewModel;

  Widget _selectCoin(final BuildContext context) {
    viewModel.titleUpdate(L.choose_currency);
    return Column(
      children: [
        SizedBox(height: 64),
        Text(
          L.choose_wallet_currency,
          style: T.textTheme.titleMedium?.copyWith(color: T.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: 8),
        ...List.generate(
          viewModel.coins.length,
          (final int i) => Observer(
            builder: (final BuildContext context) => Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: CakeListTile(
                onTap: (final BuildContext _) {
                  viewModel.unconfirmedSelectedCoin = viewModel.coins[i];
                },
                selected: viewModel.unconfirmedSelectedCoin == viewModel.coins[i],
                icon: viewModel.coins[i].strings.svg,
                text: viewModel.coins[i].strings.nameFull,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createMethodKind(final BuildContext context) {
    viewModel.titleUpdate(L.wallet);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: double.maxFinite,
        child: Column(
          children: [
            SizedBox(height: 32),
            SizedBox.square(
              dimension: 250,
              child: Assets.icons.walletNew.image(),
            ),
            Spacer(),
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
      ),
    );
  }

  @override
  Widget body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) {
        return _body(context) ?? const SizedBox.shrink();
      },
    );
  }

  Widget? _body(final BuildContext context) {
    if (viewModel.selectedCoin == null) {
      return _selectCoin(context);
    }
    if (viewModel.createMethod == null) {
      return _createMethodKind(context);
    }
    return _createMethodTabbed(context);
  }

  Widget _createMethodTabbed(final BuildContext context) {
    viewModel.titleUpdate(L.wallet);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.isPinSet) ...[
          SizedBox(height: 16),
          if (viewModel.createMethod == CreateMethod.restore)
            CustomTabBar(
              tabs: viewModel.createMethods.keys.toList(),
              selectedIndex: viewModel.formIndex,
              onTabSelected: (final int index) {
                viewModel.formIndex = index;
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              child: Assets.icons.walletNew.image(),
            ),
          SizedBox(height: 24),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FormBuilder(
              showExtra: viewModel.showExtra,
              viewModel:
                  viewModel.formBuilderViewModelList[viewModel.formIndex] as FormBuilderViewModel,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    if (viewModel.selectedCoin == null) {
      return Observer(
        builder: (final BuildContext context) => LongPrimaryButton(
          text: L.confirm,
          onPressed: viewModel.unconfirmedSelectedCoin == null
              ? null
              : () {
                  viewModel.selectedCoin = viewModel.unconfirmedSelectedCoin;
                },
        ),
      );
    }
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
          text: L.continue_,
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
