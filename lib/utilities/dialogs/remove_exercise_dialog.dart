import 'package:po_pal/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/widgets.dart';

Future<bool> showRemoveExerciseDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Remove',
    content: 'Are you sure you want to remove this exercise?',
    optionBuilder: () => {'Cancel': false, 'Remove': true},
  ).then((value) => value ?? false);
}
