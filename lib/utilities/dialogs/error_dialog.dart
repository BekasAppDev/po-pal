import 'package:po_pal/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occured',
    content: text,
    optionBuilder: () => {'Ok': null},
  );
}
