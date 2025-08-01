import 'package:cupcake/utils/tos.dart';
import 'package:cupcake/view_model/tos_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:flutter/material.dart';

class TosPage extends AbstractView {
  TosPage({super.key});

  @override
  final TosViewModel viewModel = TosViewModel();

  @override
  Widget? body(final BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Text(
          tos,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
