import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/auth/bloc/auth_states.dart';
import 'package:po_pal/utilities/dialogs/error_dialog.dart';
import 'package:po_pal/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetEmailSentDialog(context);
          }
          if (state.exception != null) {
            if (!context.mounted) return;
            await showErrorDialog(
              context,
              'No user found with that email adress',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot password'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'A link will be sent to your email adress allowing you to reset your password',
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Enter email'),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(
                      AuthEventForgotPassword(email: email),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Send password reset link"),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthEventLogOut());
                },
                child: const Text('Take me back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
