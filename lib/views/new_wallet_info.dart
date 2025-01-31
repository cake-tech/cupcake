import 'package:cupcake/view_model/new_wallet_info_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewWalletInfoScreen extends AbstractView {
  static void staticPush(
      BuildContext context, NewWalletInfoViewModel viewModel) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return NewWalletInfoScreen(viewModel: viewModel);
        },
      ),
    );
  }

  NewWalletInfoScreen({super.key, required this.viewModel});

  @override
  NewWalletInfoViewModel viewModel;

  @override
  bool get canPop => false;

  @override
  AppBar? get appBar => AppBar(
        title: Text(viewModel.screenName),
        automaticallyImplyLeading: canPop,
        actions: _getActionButton(),
      );

  List<Widget>? _getActionButton() {
    if (viewModel.page.topAction == null &&
        viewModel.page.topActionText == null) {
      return null;
    }
    if (viewModel.page.topActionText != null &&
        viewModel.page.topAction == null) {
      return [
        TextButton(
          onPressed: viewModel.nextPage,
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

  List<Widget> _getBottomActionButtons() {
    return List.generate(viewModel.page.actions.length, (index) {
      final action = viewModel.page.actions[index];
      final isLast = index + 1 == viewModel.page.actions.length;
      final callback = switch (action.type) {
        NewWalletActionType.function => action.function!,
        NewWalletActionType.nextPage => viewModel.nextPage,
      };
      return Expanded(
        child: LongPrimaryButton(
          padding: EdgeInsets.only(right: isLast ? 0 : 16.0),
          textWidget: action.text,
          icon: null,
          onPressed: callback,
          backgroundColor: WidgetStatePropertyAll(action.backgroundColor),
          width: null,
        ),
      );
    });
  }

  @override
  Widget? body(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 0, bottom: 16),
      child: Column(
        children: [
          if (viewModel.page.lottieAnimation != null)
            viewModel.page.lottieAnimation!,
          ...viewModel.page.texts,
          const Spacer(),
          SizedBox(
            width: double.maxFinite,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: _getBottomActionButtons(),
            ),
          )
        ],
      ),
    ));
  }
}
