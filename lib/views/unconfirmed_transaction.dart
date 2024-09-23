import 'package:cup_cake/utils/call_throwable.dart';
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
          icon: Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          label: "Cancel",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.check_circle, color: Colors.green),
            label: "Confirm"),
      ],
      onTap: (int index) async {
        if (index == 0) {
          await callThrowable(context,
              () async => await viewModel.cancelCallback(context), "Canceling");
          if (!context.mounted) return;
          Navigator.of(context).pop();
        } else {
          await callThrowable(context,
              () async => await viewModel.confirmCallback(context), "Spending");
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
    );
  }
}
