import 'package:cupcake/utils/alerts/widget.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/views/widgets/base_text_form_field.dart';
import 'package:flutter/material.dart';

class IntegerConfigElement extends StatelessWidget {
  IntegerConfigElement({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChange,
  });

  final String title;
  final String? hint;
  final int value;
  final Function(int val) onChange;
  late final ctrl = TextEditingController(text: value.toString());
  @override
  Widget build(final BuildContext context) {
    return ListTile(
      title: Text(title),
      onLongPress: () {
        CupcakeConfig.instance.debug = true;
        CupcakeConfig.instance.save();
      },
      subtitle: BaseTextFormField(
        controller: ctrl,
        onFieldSubmitted: (final String value) {
          final i = int.tryParse(value);
          if (i == null) return;
          onChange(i);
        },
      ),
      trailing: hint == null
          ? null
          : IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showAlertWidget(
                  context: context,
                  title: title,
                  body: [Text(hint ?? "")],
                );
              },
            ),
    );
  }
}
