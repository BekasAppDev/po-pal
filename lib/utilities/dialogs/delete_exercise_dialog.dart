import 'package:po_pal/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/widgets.dart';

Future<bool> showDeleteExerciseDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this exercise?',
    optionBuilder: () => {'Cancel': false, 'Delete': true},
  ).then((value) => value ?? false);
}
