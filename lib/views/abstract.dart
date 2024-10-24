import 'dart:async';

import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/material.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter_svg/svg.dart';

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
  Widget build(BuildContext context) {
    return realBuild(context);
  }
}

// ignore: must_be_immutable
class AbstractView extends StatefulWidget {
  @override
  // ignore: no_logic_in_create_state
  State<AbstractView> createState() {
    state ??= _AbstractViewState(realBuild: build);
    return state!;
  }

  AppLocalizations get L => viewModel.L;

  Future<void> initState(BuildContext context) async {}

  State<AbstractView>? state;

  AbstractView({super.key});

  final viewModel = ViewModel();

  late final appBar = viewModel.screenName.isEmpty
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

  Widget? body(BuildContext context) => null;

  bool _internalIsInitStateCalled = false;

  bool canPop = true;

  Drawer? drawer;

  Widget build(BuildContext context) {
    viewModel.register(context);
    if (!_internalIsInitStateCalled) {
      _internalIsInitStateCalled = true;
      unawaited(initState(context));
    }
    return PopScope(
      canPop: canPop,
      onPopInvoked: (bool pop) {
        print(pop);
      },
      child: Scaffold(
        appBar: appBar,
        body: body(context),
        endDrawer: drawer,
        floatingActionButton: floatingActionButton(context),
        bottomNavigationBar: bottomNavigationBar(context),
      ),
    );
  }

  Widget? bottomNavigationBar(BuildContext context) => null;

  Widget? floatingActionButton(BuildContext context) => null;

  void markNeedsBuild(BuildContext context) {
    state!.setState(() {});
  }
}

class CupcakeAppbarTitle extends StatelessWidget {
  const CupcakeAppbarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/icons/icon-white.svg", height: 32, width: 32, color: Colors.white),
          const SizedBox(
            width: 12,
          ),
          const Text(
            "Cupcake",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
