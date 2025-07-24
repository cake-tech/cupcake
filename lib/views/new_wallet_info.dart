import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/new_wallet_info_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NewWalletInfoScreen extends AbstractView {
  NewWalletInfoScreen({
    super.key,
    required final List<NewWalletInfoPage> pages,
  }) : viewModel = NewWalletInfoViewModel(pages);

  @override
  bool get canPop => false;

  @override
  NewWalletInfoViewModel viewModel;

  @override
  PreferredSizeWidget? get appBar => PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Observer(
          builder: (final context) => AppBar(
            title: Text(viewModel.screenName),
            automaticallyImplyLeading: canPop,
            actions: _getActionButton(),
          ),
        ),
      );

  List<Widget>? _getActionButton() {
    if (viewModel.page.topAction == null && viewModel.page.topActionText == null) {
      return null;
    }
    if (viewModel.page.topActionText != null && viewModel.page.topAction == null) {
      return [
        TextButton(
          onPressed: () => viewModel.currentPageIndex++,
          child: viewModel.page.topActionText!,
        ),
      ];
    }
    return [
      TextButton(
        onPressed: viewModel.page.topAction!,
        child: viewModel.page.topActionText!,
      ),
    ];
  }

  List<Widget> _getBottomActionButtons(final BuildContext context) {
    return List.generate(viewModel.page.actions.length, (final index) {
      final action = viewModel.page.actions[index];
      final isLast = index + 1 == viewModel.page.actions.length;
      final Function(BuildContext c, VoidCallback nextPage) callback = switch (action.type) {
        NewWalletActionType.function => action.function!,
        NewWalletActionType.nextPage => (final _, final __) => viewModel.currentPageIndex++,
      };
      if (index != 0 || viewModel.page.actions.length == 1) {
        return Expanded(
          child: LongPrimaryButton(
            padding: EdgeInsets.only(right: isLast ? 0 : 16.0),
            text: action.text,
            icon: null,
            onPressed: () => callback(context, () => viewModel.currentPageIndex++),
            width: null,
          ),
        );
      }
      return Expanded(
        child: LongSecondaryButton(
          T,
          padding: EdgeInsets.only(right: isLast ? 0 : 16.0),
          text: action.text,
          icon: null,
          onPressed: () => callback(context, () => viewModel.currentPageIndex++),
          width: null,
        ),
      );
    });
  }

  @override
  Widget? body(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 0),
      child: SafeArea(
        top: false,
        child: Observer(
          builder: (final context) => Column(
            children: [
              if (viewModel.page.svgIcon != null) viewModel.page.svgIcon!,
              ...viewModel.page.texts,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.maxFinite,
        child: Observer(
          builder: (final context) => Row(
            children: _getBottomActionButtons(context),
          ),
        ),
      ),
    );
  }
}
