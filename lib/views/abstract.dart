import 'dart:async';

import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/native_animation_type.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
  _AbstractViewState({required this.realBuild, required this.realInitState});

  Widget Function(BuildContext context) realBuild;
  void Function(BuildContext context) realInitState;

  @override
  void initState() {
    realInitState(context);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return realBuild(context);
  }
}

class ViewModelSimple extends ViewModel {
  @override
  bool hasBackground = true;
}

class AbstractView extends StatefulWidget {
  AbstractView({super.key});
  Future<dynamic> push(final BuildContext context) {
    Widget builder(final context) {
      return this;
    }

    return Navigator.of(context).push(
      switch (nativeAnimationType) {
        NativeAnimationType.cupertino => CupertinoPageRoute(
            builder: builder,
          ),
        NativeAnimationType.material => MaterialPageRoute(
            builder: builder,
          ),
      },
    );
  }

  Future<dynamic> pushReplacement(final BuildContext context) {
    Widget builder(final context) {
      return this;
    }

    return Navigator.of(context).pushReplacement(
      switch (nativeAnimationType) {
        NativeAnimationType.cupertino => CupertinoPageRoute(
            builder: builder,
          ),
        NativeAnimationType.material => MaterialPageRoute(
            builder: builder,
          ),
      },
    );
  }

  final ViewModel viewModel = ViewModelSimple();

  @override
  // ignore: no_logic_in_create_state
  State<AbstractView> createState() {
    state ??= _AbstractViewState(realBuild: build, realInitState: initState);
    return state!;
  }

  AppLocalizations get L => viewModel.L;

  ThemeData get T => viewModel.T;

  Future<void> initState(final BuildContext context) async {}

  State<AbstractView>? state;

  Widget get popButton {
    if (!automaticallyImplyLeading) {
      return Text(""); // No we cannot use Container(), appbar just goes away???
    }
    return IconButton(
      onPressed: () => Navigator.of(viewModel.c!).pop(),
      icon: Icon(
        CupertinoIcons.left_chevron,
        size: 22,
      ),
    );
  }

  bool get automaticallyImplyLeading => canPop;

  PreferredSizeWidget? get appBar => viewModel.screenName.isEmpty
      ? null
      : CupertinoNavigationBar(
          enableBackgroundFilterBlur: false,
          backgroundColor: Colors.transparent,
          automaticBackgroundVisibility: false,
          leading: popButton,
          automaticallyImplyLeading: automaticallyImplyLeading,
          automaticallyImplyMiddle: false,
          transitionBetweenRoutes: false,
          middle: Text(
            viewModel.screenName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 22),
          ),
          border: null,
        );
  //  AppBar(
  //       title: viewModel.screenName.toLowerCase() != "cupcake"
  //           ? Text(
  //               viewModel.screenName,
  //               style: const TextStyle(color: Colors.white),
  //             )
  //           : const CupcakeAppbarTitle(),
  //       automaticallyImplyLeading: canPop,
  //     );

  Widget? body(final BuildContext context) => null;

  Widget? _body(final BuildContext context) {
    final b = body(context);
    if (b == null) return b;
    final navBar = bottomNavigationBar(context);
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: Stack(
        children: [
          Observer(
            builder: (final context) => viewModel.hasBackground
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF1B284A),
                          Color(0xFF0F1A36),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
          Observer(
            builder: (final context) => viewModel.hasPngBackground
                ? Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Assets.backgroundForWallethome.path),
                        fit: BoxFit.cover,
                        opacity: 0.12,
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
          Positioned.fill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appBar != null) appBar!,
                Expanded(child: b),
                if (navBar != null)
                  SafeArea(
                    top: false,
                    child: navBar,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get canPop => viewModel.canPop;

  Widget build(final BuildContext context) {
    viewModel.register(context);
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        body: _body(context),
        floatingActionButton: floatingActionButton(context),
      ),
    );
  }

  Widget? bottomNavigationBar(final BuildContext context) => null;

  Widget? floatingActionButton(final BuildContext context) => null;
}
