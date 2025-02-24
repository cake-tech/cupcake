import 'dart:async';

import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/widgets/cupcake_appbar_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Since there is no performance penalty for using stateful widgets I would just
// use them everywhere, but honestly all I need in stateless widgets is easy
// access to the markNeedsBuild function, which rebuilds the widget - so I
// expose this function, to be called whenever we do need to rebuild the entire
// widget, in scenarios such as
// - navigation change, when user comes back to a screen from another
// - bigger background change (user created a wallet -> so we remove the landing
//   and show wallet selector)
// and due to the fact that we don't use stateful widget we can directly use
// viewmodel, without any extra code involved in doing that.

class _AbstractViewState extends State<AbstractView> {
  _AbstractViewState({required this.realBuild});

  Widget Function(BuildContext context) realBuild;

  @override
  Widget build(final BuildContext context) {
    return realBuild(context);
  }
}

class AbstractView extends StatefulWidget {
  Future<void> push(final BuildContext context) async {
    await Navigator.of(context).push(CupertinoPageRoute(
      builder: (final context) {
        return this;
      },
    ));
  }

  final viewModel = ViewModel();

  @override
  // ignore: no_logic_in_create_state
  State<AbstractView> createState() {
    state ??= _AbstractViewState(realBuild: build);
    return state!;
  }

  AppLocalizations get L => viewModel.L;

  Future<void> initState(final BuildContext context) async {}

  State<AbstractView>? state;

  AbstractView({super.key});

  get appBar => viewModel.screenName.isEmpty
      ? null
      : AppBar(
          title: viewModel.screenName.toLowerCase() != "cupcake"
              ? Text(
                  viewModel.screenName,
                  style: const TextStyle(color: Colors.white),
                )
              : const CupcakeAppbarTitle(),
          automaticallyImplyLeading: canPop,
        );

  Widget? body(final BuildContext context) => null;

  bool _internalIsInitStateCalled = false;

  bool get canPop => viewModel.canPop;

  Drawer? drawer;

  Widget build(final BuildContext context) {
    viewModel.register(context);
    if (!_internalIsInitStateCalled) {
      _internalIsInitStateCalled = true;
      unawaited(initState(context));
    }
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: appBar,
        body: body(context),
        endDrawer: drawer,
        floatingActionButton: floatingActionButton(context),
        bottomNavigationBar: bottomNavigationBar(context),
      ),
    );
  }

  Widget? bottomNavigationBar(final BuildContext context) => null;

  Widget? floatingActionButton(final BuildContext context) => null;
}
