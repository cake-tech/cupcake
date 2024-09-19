import 'package:cup_cake/view_model/abstract.dart';
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

  State<AbstractView>? state;

  Future<void> push(BuildContext context) => throw UnimplementedError();
  AbstractView({super.key});

  final viewModel = ViewModel();

  late final appBar = AppBar(
    title: Text(viewModel.screenName),
  );

  Widget? body(BuildContext context) => null;

  Widget build(BuildContext context) {
    viewModel.register(context);
    return Scaffold(
      appBar: appBar,
      body: body(context),
      floatingActionButton: floatingActionButton(context),
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }

  Widget? bottomNavigationBar(BuildContext context) => null;

  Widget? floatingActionButton(BuildContext context) => null;

  void markNeedsBuild(BuildContext context) {
    state!.setState(() {});
  }
}
