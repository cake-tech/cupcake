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
    required this.viewModel,
  });

  @override
  final CreateWalletViewModel viewModel;

  Widget _selectCoin(final BuildContext context) {
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
                icon: viewModel.coins[i].strings.svg.svg(),
                text: viewModel.coins[i].strings.nameFull,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _createMethodKind(final BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32),
                  SizedBox.square(
                    dimension: 250,
                    child: Assets.icons.walletNew.image(),
                  ),
                  // Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(42.0),
                    child: Text.rich(
                      markdownText(L.wallet_creation_onboard),
                      style: TextStyle(color: T.colorScheme.onSurface, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Spacer(),
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
                ],
              ),
            ),
          ),
        ),
        LongSecondaryButton(
          T,
          onPressed: () async {
            await CreateWallet(
              viewModel: viewModel.copyWith(newCreateMethod: CreateMethod.restore),
            ).pushReplacement(context);
          },
          text: L.restore_wallet,
        ),
        LongPrimaryButton(
          onPressed: () async {
            await CreateWallet(
              viewModel: viewModel.copyWith(newCreateMethod: CreateMethod.create),
            ).pushReplacement(context);
          },
          text: L.create_new_wallet,
        ),
      ],
    );
  }

  @override
  Widget body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) {
        return SafeArea(child: _body(context) ?? const SizedBox.shrink());
      },
    );
  }

  Widget? _body(final BuildContext context) {
    if (viewModel.selectedCoin == null) {
      viewModel.titleUpdate(L.choose_currency);
      return _selectCoin(context);
    }
    if (viewModel.createMethod == null) {
      viewModel.titleUpdate(L.wallet);
      return _createMethodKind(context);
    }
    if (viewModel.createMethod == CreateMethod.restore) {
      viewModel.titleUpdate(L.restore_wallet);
    } else {
      viewModel.titleUpdate(L.create_new_wallet);
    }
    return _createMethodTabbed(context);
  }

  Widget _createMethodTabbed(final BuildContext context) {
    if (viewModel.isPinSet) {
      return SingleChildScrollView(child: _createMethodTabbedPage(context));
    }
    return _createMethodTabbedPage(context);
  }

  Widget _createMethodTabbedPage(final BuildContext context) {
    viewModel.formBuilderViewModelList[viewModel.formIndex].scaffoldContext = context;
    for (int i = 0; i < viewModel.formBuilderViewModelList.length; i++) {
      viewModel.formBuilderViewModelList[i].scaffoldContext = context;
      for (int j = 0; j < viewModel.formBuilderViewModelList[i].formElements.length; j++) {
        viewModel.formBuilderViewModelList[i].formElements[j].errorHandler = viewModel.errorHandler;
      }
    }
    final form = FormBuilder(
      showExtra: viewModel.showExtra,
      viewModel: viewModel.formBuilderViewModelList[viewModel.formIndex] as FormBuilderViewModel,
    );
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
        if (!viewModel.isPinSet)
          Expanded(
            child: form,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: form,
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
                  CreateWallet(
                    viewModel:
                        viewModel.copyWith(newSelectedCoin: viewModel.unconfirmedSelectedCoin),
                  ).pushReplacement(context);
                },
        ),
      );
    }
    if (!viewModel.isPinSet) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.hasAdvancedOptions)
          Row(
            children: [
              Spacer(),
              Checkbox(
                value: viewModel.showExtra,
                onChanged: (final bool? value) {
                  viewModel.showExtra = value ?? false;
                  if (!viewModel.showExtra) {
                    final count = viewModel.formBuilderViewModelList.length;
                    for (int i = 0; i < count; i++) {
                      final formCount = viewModel.formBuilderViewModelList[i].formElements.length;
                      for (int j = 0; j < formCount; j++) {
                        if (viewModel.formBuilderViewModelList[i].formElements[j].isExtra) {
                          viewModel.formBuilderViewModelList[i].formElements[j].clear();
                        }
                      }
                    }
                  }
                },
              ),
              Text(
                L.add_passphrase,
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
            ],
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
