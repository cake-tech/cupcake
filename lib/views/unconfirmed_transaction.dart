import 'package:cup_cake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class UnconfirmedTransactionView extends AbstractView {
  static Future<void> staticPush(
      BuildContext context, UnconfirmedTransactionViewModel viewModel) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => UnconfirmedTransactionView(viewModel: viewModel),
      ),
    );
  }

  UnconfirmedTransactionView({super.key, required this.viewModel});

  @override
  final UnconfirmedTransactionViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    final keys = viewModel.destMap.keys.toList();
    return ListView.builder(
        itemCount: keys.length,
        itemBuilder: (BuildContext context, int index) {
          final key = keys[index];
          final value = viewModel.destMap[key]!;

          return Text("$key => $value");
        });
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.cancel),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
        ),
      ],
      onTap: (int index) {
        if (index == 0) {
          Navigator.of(context).pop();
          viewModel.cancelCallback();
        } else {
          Navigator.of(context).pop();
          viewModel.confirmCallback();
        }
      },
    );
  }
}
