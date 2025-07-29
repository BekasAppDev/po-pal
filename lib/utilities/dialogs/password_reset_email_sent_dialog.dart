import 'package:po_pal/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/widgets.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'Please check your email',
    optionBuilder: () => {'Ok': null},
  );
}
